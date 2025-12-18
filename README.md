# ArduPilot MAVLink SITL Reference Implementation

A Docker-based ArduPilot Software-in-the-Loop (SITL) environment with MAVProxy integration, designed for understanding MAVLink communication protocols and testing ground control station (GCS) applications.

- [ArduPilot MAVLink SITL Reference Implementation](#ardupilot-mavlink-sitl-reference-implementation)
  - [Overview](#overview)
  - [Quick Start](#quick-start)
  - [Use Cases](#use-cases)
  - [Vehicle Profiles](#vehicle-profiles)
    - [Single Copter (Default)](#single-copter-default)
    - [Single Plane](#single-plane)
    - [Dual Plane](#dual-plane)
  - [Architecture](#architecture)
  - [Project Structure](#project-structure)
  - [MAVLink Messages Demonstrated](#mavlink-messages-demonstrated)
  - [Requirements](#requirements)
  - [Wireshark Packet Capture](#wireshark-packet-capture)
  - [Customization](#customization)
    - [Change Starting Location](#change-starting-location)
    - [Adjust Simulation Speed](#adjust-simulation-speed)
    - [Add Custom Parameters](#add-custom-parameters)
  - [Troubleshooting](#troubleshooting)
  - [Contributing](#contributing)
  - [Resources](#resources)

## Overview

This repository provides a ready-to-run ArduPilot SITL simulation that:

- Runs entirely in Docker (cross-platform: macOS, Windows, Linux)
- Supports multiple vehicle types (copter, plane)
- Exposes standard MAVLink ports for GCS connectivity
- Includes MAVProxy for message routing
- Enables Wireshark packet capture for protocol analysis

## Quick Start

```bash
# Clone repository
git clone git@github.com:noda-ai/ardupilot-mavlink-sitl-reference.git
cd ardupilot-mavlink-sitl

# Start single copter simulation
docker compose --profile copter up --build

# In another terminal, connect QGroundControl to UDP port 14550
```

**Complete setup instructions**: See [Quick Start Guide](docs/01-quick-start.md)

## Use Cases

This reference implementation is ideal for:

- **GCS Development**: Test your ground control station against a real ArduPilot autopilot
- **MAVLink Protocol Learning**: Observe actual message flows in a working system
- **Integration Testing**: Validate MAVLink implementations before hardware testing
- **Algorithm Development**: Test mission planning and control algorithms
- **Education**: Learn UAV communication protocols hands-on

## Vehicle Profiles

Three pre-configured profiles are available:

### Single Copter (Default)

```bash
docker compose --profile copter up
```

- Best for: Basic MAVLink testing, mission planning, simple demonstrations
- Vehicle: Quadcopter in "+" configuration
- MAVLink System ID: 1
- Ports: 14550-14552

### Single Plane

```bash
docker compose --profile plane up
```

- Best for: Fixed-wing specific testing, longer-range missions
- Vehicle: Generic plane
- MAVLink System ID: 1
- Ports: 14550-14552

### Dual Plane

```bash
docker compose --profile dual-plane up
```

- Best for: Multi-vehicle coordination, swarm testing
- Vehicles: Two planes with different System IDs
- Plane 1: System ID 1, Ports 14550-14552
- Plane 2: System ID 2, Ports 14560-14562

## Architecture

```PlainText
┌─────────────────────────┐
│  QGroundControl (Host)  │
│  or other GCS           │
└───────────┬─────────────┘
            │ UDP 14550-14552
            │
    ┌───────▼────────┐
    │ Docker Network │
    │                │
    │  ┌──────────┐  │
    │  │ ArduPilot│  │
    │  │   SITL   │  │
    │  └────┬─────┘  │
    │       │        │
    │  ┌────▼─────┐  │
    │  │ MAVProxy │  │
    │  └──────────┘  │
    └────────────────┘
```

## Project Structure

```PlainText
ardupilot-mavlink-sitl/
├── README.md                    # This file
├── docker-compose.yml           # Vehicle configurations
├── .env.example                 # Environment template
├── ardupilot-sitl/
│   ├── Dockerfile               # ArduPilot SITL image
│   ├── entrypoint.sh            # Startup script
│   └── custom_params.parm       # Vehicle parameters
└── docs/
    └── 01-quick-start.md        # Setup guide
```

## MAVLink Messages Demonstrated

This SITL demonstrates the full spectrum of common MAVLink messages:

**Basic Connection** (Tier 1):

- HEARTBEAT, SYS_STATUS, GLOBAL_POSITION_INT, ATTITUDE, BATTERY_STATUS

**Mission Execution** (Tier 2):

- MISSION_COUNT, MISSION_ITEM_INT, MISSION_ACK, MISSION_CURRENT, COMMAND_LONG

**Advanced Features** (Tier 3):

- MISSION_ITEM_REACHED, GPS_RAW_INT, STATUSTEXT, HOME_POSITION

See [Quick Start Guide](docs/01-quick-start.md) for detailed message documentation.

## Requirements

- Docker Desktop 20.10+ (includes Docker Compose)
- QGroundControl (for visualization and control)
- 4GB RAM available for Docker
- 10GB disk space

## Wireshark Packet Capture

Capture MAVLink traffic for analysis:

```bash
# macOS/Linux
sudo tcpdump -i lo0 -w mavlink.pcap udp port 14550

# Windows WSL
sudo tcpdump -i any -w mavlink.pcap udp port 14550
```

Open `mavlink.pcap` in Wireshark with MAVLink dissector enabled.

## Customization

### Change Starting Location

Edit `docker-compose.yml`:

```yaml
environment:
  - LAT=37.7749    # San Francisco latitude
  - LON=-122.4194  # San Francisco longitude
  - ALT=0          # Altitude (meters)
  - DIR=0          # Initial heading (degrees)
```

### Adjust Simulation Speed

```yaml
environment:
  - SPEEDUP=1  # Real-time
  # - SPEEDUP=2  # 2x speed
  # - SPEEDUP=0.5  # Half speed (more stable)
```

### Add Custom Parameters

Edit `ardupilot-sitl/custom_params.parm`:

```
# Add any ArduPilot parameters
ARMING_CHECK,0
SYSID_THISMAV,42
```

## Troubleshooting

**Container won't start**:

```bash
docker compose logs
docker compose build --no-cache
```

**QGC won't connect**:

- Check port 14550 not in use: `lsof -i :14550`
- Verify firewall allows UDP traffic
- Confirm SITL is running: `docker compose ps`

**No telemetry in QGC**:

- Check `host.docker.internal` resolves (requires Docker Desktop)
- Try explicit IP in docker-compose.yml: `GCS_IP_1=192.168.1.x`

More solutions: [Quick Start Guide - Troubleshooting](docs/01-quick-start.md#troubleshooting)

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Resources

- [ArduPilot Documentation](https://ardupilot.org/)
- [MAVLink Protocol Guide](https://mavlink.io/en/)
- [QGroundControl User Guide](https://docs.qgroundcontrol.com/master/en/)
- [MAVProxy Documentation](https://ardupilot.org/mavproxy/)
