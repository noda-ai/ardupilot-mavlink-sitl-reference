# Useful links:
# http://ardupilot.org/dev/docs/setting-up-sitl-on-linux.html
# https://github.com/ArduPilot/ardupilot/blob/master/BUILD.md
# https://ardupilot.org/dev/docs/sitl-with-gazebo.html

ARG BASE_IMAGE="ubuntu"
ARG TAG="22.04"
FROM ${BASE_IMAGE}:${TAG}

ARG VEHICLES="copter,plane"
ARG USER_NAME=ardu
ARG USER_UID=1000
ARG USER_GID=1000
ARG DEBIAN_FRONTEND=noninteractive

ARG SKIP_AP_EXT_ENV=0
ARG SKIP_AP_GRAPHIC_ENV=1
ARG SKIP_AP_COV_ENV=1
ARG SKIP_AP_GIT_CHECK=1
ARG DO_AP_STM_ENV=1

# Create the user and user home directory
RUN groupadd ${USER_NAME} --gid ${USER_GID}\
    && useradd -l -m ${USER_NAME} -u ${USER_UID} -g ${USER_GID} -s /bin/bash

ENV TZ=UTC
RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && git config --global url."https://github.com/".insteadOf git://github.com/

# User sudo privledges bc why not
RUN usermod -aG sudo ${USER_NAME} \
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

RUN git clone --branch Tracker-4.6.3 --single-branch  https://github.com/ArduPilot/ardupilot.git ardupilot
#RUN git clone https://github.com/ArduPilot/ardupilot.git ardupilot
WORKDIR ardupilot/
RUN git submodule update --init --recursive

# Install prereqs
RUN SKIP_AP_EXT_ENV=$SKIP_AP_EXT_ENV SKIP_AP_GRAPHIC_ENV=$SKIP_AP_GRAPHIC_ENV SKIP_AP_COV_ENV=$SKIP_AP_COV_ENV SKIP_AP_GIT_CHECK=$SKIP_AP_GIT_CHECK \
    DO_AP_STM_ENV=$DO_AP_STM_ENV \
    AP_DOCKER_BUILD=1 \
    USER=${USER_NAME} \
    Tools/environment_install/install-prereqs-ubuntu.sh -y

# Configure and build simulated vehicles
RUN ./waf distclean
RUN ./waf configure --board sitl
# Build vehicles based on VEHICLES arg
RUN for vehicle in $(echo ${VEHICLES} | tr ',' ' '); do \
        echo "Building $vehicle..." && \
        ./waf $vehicle; \
    done
# RUN ./waf copter
# RUN ./waf sub

ENV PATH="/home/${USER_NAME}/.local/bin:${PATH}"

# Simulation vars
# Send mavlink over host machine's UDP ports 24540, 24541, 24542..
ENV BASE_VEHICLE_PORT=${BASE_VEHICLE_PORT:-24540}
ENV VEHICLE_PROTOCOL=${VEHICLE_PROTOCOL:-udp}
ENV ENDPOINT_HOST=${ENDPOINT_HOST:-maestro-client}
ENV GCS_IP_1=${GCS_IP_1:-host.docker.internal}
ENV GCS_IP_2=${GCS_IP_2:-host.docker.internal}
ENV GCS_IP_3=${GCS_IP_3:-host.docker.internal}
ENV INSTANCE=${INSTANCE:-0}
ENV SYSID_THISMAV=${SYSID_THISMAV:-1}
ENV LAT=$LAT
ENV LON=$LON
ENV ALT=$ALT
ENV DIR=${DIR:-0}
ENV FRAME=${FRAME:-plane}
ENV SPEEDUP=${SPEEDUP:-1}
ENV VEHICLE=${VEHICLE:-ArduPlane}
ENV MAVPROXY_ENABLED=${MAVPROXY_ENABLED-1}

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY custom_params.parm /home/${USER_NAME}/custom_params.parm


ENV USE_MAVPROXY=${USE_MAVPROXY}
ENTRYPOINT ["/entrypoint.sh"]
