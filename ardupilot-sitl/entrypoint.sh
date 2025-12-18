#!/bin/bash
set -e

# Build parameter file path for any custom parameters you want to pass to simulated vehicles
CUSTOM_PARAM_FILE="/home/ardu/custom_params.parm"

if [ "$MAVPROXY_ENABLED" -eq 1 ]; then
    echo "Starting with MAVProxy"

    # Calculate auto UDP port based on SYS_ID
    AUTO_UDP_PORT_1=$((BASE_VEHICLE_PORT + SYSID_THISMAV - 1))
    AUTO_OUT_1="${VEHICLE_PROTOCOL}:${ENDPOINT_HOST}:$AUTO_UDP_PORT_1" # 24540-24559 <-- mavsdk

    # Second port is +100 from first port
    AUTO_UDP_PORT_2=$((AUTO_UDP_PORT_1 + 100))
    AUTO_OUT_2="${VEHICLE_PROTOCOL}:${ENDPOINT_HOST}:$AUTO_UDP_PORT_2" # 24640-24659 <--- pymavlink

    # Third port is +200 from first port
    AUTO_UDP_PORT_3=$((AUTO_UDP_PORT_1 + 200))
    AUTO_OUT_3="${VEHICLE_PROTOCOL}:${ENDPOINT_HOST}:$AUTO_UDP_PORT_3" # 24740-24759 <--- unused currently

    # Add to OUT_PARAMS and process and additionally provided ports
    # Always include 14550-14552 for GCS (host.docker.internal for local host or LAN accessible IP for remote host)
    OUT_PARAMS="--out=$AUTO_OUT_1 --out=$AUTO_OUT_2 --out=$AUTO_OUT_3 --out=udp:$GCS_IP_1:14550 --out=udp:$GCS_IP_2:14551 --out=udp:$GCS_IP_3:14552"
    if [ -n "${MAVPROXY_OUTS}" ]; then
        # Split by comma and process each endpoint
        IFS=',' read -ra OUTPUTS <<< "${MAVPROXY_OUTS}"
        for output in "${OUTPUTS[@]}"; do
            # Trim whitespace
            output=$(echo "$output" | xargs)
            OUT_PARAMS="$OUT_PARAMS --out=$output"
        done
    fi

    echo "Auto UDP ports: ${AUTO_UDP_PORT_1}, ${AUTO_UDP_PORT_2}, ${AUTO_UDP_PORT_3} (MAVLink System ID: $SYSID_THISMAV)"
    echo "MAVProxy outputs: $OUT_PARAMS"

    # Add custom parameter file if environment variables are set
    PARAM_FILE_ARG=""
    if [ -n "$CUSTOM_PARAM_FILE" ]; then
        PARAM_FILE_ARG="--add-param-file $CUSTOM_PARAM_FILE"
        echo "Using custom parameter file: $CUSTOM_PARAM_FILE"
    fi

    exec Tools/autotest/sim_vehicle.py \
        --vehicle ${VEHICLE} -I${INSTANCE} \
        --custom-location=${LAT},${LON},${ALT},${DIR} -w \
        --frame ${FRAME} ${MODEL:+--model ${MODEL}} --no-rebuild --speedup ${SPEEDUP} \
        $OUT_PARAMS --sysid ${SYSID_THISMAV} $PARAM_FILE_ARG

else
    echo "Starting without MAVProxy"

    # Add custom parameter file if environment variables are set
    PARAM_FILE_ARG=""
    if [ -n "$CUSTOM_PARAM_FILE" ]; then
        PARAM_FILE_ARG="--add-param-file $CUSTOM_PARAM_FILE"
        echo "Using custom parameter file: $CUSTOM_PARAM_FILE"
    fi

    exec Tools/autotest/sim_vehicle.py --no-mavproxy \
        --vehicle ${VEHICLE} -I${INSTANCE} \
        --custom-location=${LAT},${LON},${ALT},${DIR} -w \
        --frame ${FRAME} --no-rebuild --speedup ${SPEEDUP} $PARAM_FILE_ARG
fi
