# Quick Start Guide

This guide will get you from zero to a running ArduPilot SITL with QGroundControl connected in under 10 minutes.

- [Quick Start Guide](#quick-start-guide)
  - [Prerequisites](#prerequisites)
  - [System Requirements](#system-requirements)
  - [Installation Steps](#installation-steps)
    - [Step 1: Clone or Download Repository](#step-1-clone-or-download-repository)
    - [Step 2: Build and Start ArduPilot SITL](#step-2-build-and-start-ardupilot-sitl)
      - [Option A: Single Copter (Recommended for First Time)](#option-a-single-copter-recommended-for-first-time)
      - [Option B: Single Plane](#option-b-single-plane)
      - [Option C: Two Planes (Multi-vehicle)](#option-c-two-planes-multi-vehicle)
    - [Step 3: Verify SITL is Running](#step-3-verify-sitl-is-running)
    - [Step 4: Connect QGroundControl](#step-4-connect-qgroundcontrol)
      - [First Time Setup](#first-time-setup)
      - [Subsequent Connections](#subsequent-connections)
    - [Step 5: Verify Connection](#step-5-verify-connection)
    - [Step 6: Verify MAVLink Communication](#step-6-verify-mavlink-communication)
  - [What You Have Now](#what-you-have-now)
  - [Quick Test: Arm the Vehicle](#quick-test-arm-the-vehicle)
    - [For Copter](#for-copter)
    - [For Plane](#for-plane)
  - [Uploading a Simple Mission](#uploading-a-simple-mission)
  - [Stopping the Simulation](#stopping-the-simulation)
  - [Troubleshooting](#troubleshooting)
    - [Docker Build Fails](#docker-build-fails)
    - [Container Starts But No MAVProxy Output](#container-starts-but-no-mavproxy-output)
    - [QGroundControl Won't Connect](#qgroundcontrol-wont-connect)
    - [Docker Desktop Not Running](#docker-desktop-not-running)
    - [Performance Issues](#performance-issues)
    - [Mission Upload Fails](#mission-upload-fails)
  - [Next Steps](#next-steps)
  - [MAVLink Message Reference](#mavlink-message-reference)

## Prerequisites

Before starting, ensure you have:

- **Docker Desktop** installed and running
  - macOS: [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
  - Windows: [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
  - Linux: [Docker Engine](https://docs.docker.com/engine/install/)
- **QGroundControl** installed
  - Download: [QGroundControl](https://docs.qgroundcontrol.com/master/en/qgc-user-guide/getting_started/download_and_install.html)
  - All platforms supported (Windows, macOS, Linux)
- **Minimum 4GB RAM** available for Docker
- **10GB disk space** for Docker images

## System Requirements

- **Operating System**: macOS, Windows 10/11, Ubuntu 20.04+, or WSL2
- **Docker**: Version 20.10 or higher
- **Network**: UDP ports 14550-14552 available (not blocked by firewall)

## Installation Steps

### Step 1: Clone or Download Repository

```bash
git clone <repository-url>
cd ardupilot-mavlink-sitl
```

### Step 2: Build and Start ArduPilot SITL

Choose one of the following profiles based on what you want to test:

#### Option A: Single Copter (Recommended for First Time)

```bash
docker compose --profile copter up --build
```

#### Option B: Single Plane

```bash
docker compose --profile plane up --build
```

#### Option C: Two Planes (Multi-vehicle)

```bash
docker compose --profile dual-plane up --build
```

**Initial build time**: 5-10 minutes (downloads ArduPilot and builds SITL)  
**Subsequent starts**: 5-10 seconds

### Step 3: Verify SITL is Running

You should see output similar to:

```PlainText
ardupilot-copter  | Starting with MAVProxy
ardupilot-copter  | Auto UDP ports: 24540, 24640, 24740 (MAVLink System ID: 1)
ardupilot-copter  | MAVProxy outputs: --out=udp:maestro-client:24540 ...
ardupilot-copter  |
ardupilot-copter  | Init ArduCopter
ardupilot-copter  | 
ardupilot-copter  | GPS lock at 0 meters
ardupilot-copter  | 
ardupilot-copter  | Flight battery 100 percent
ardupilot-copter  | 
ardupilot-copter  | MAVProxy is running
ardupilot-copter  | AP: PreArm: RC not calibrated
```

**Key indicators of success**:

- ✅ "MAVProxy is running"
- ✅ "GPS lock at 0 meters"
- ✅ "Flight battery 100 percent"
- ✅ Heartbeat messages appearing (scrolling text)

**Common warnings you can ignore**:

- "PreArm: RC not calibrated" - Normal for SITL without RC input
- "PreArm: Compass not calibrated" - Normal for initial startup

### Step 4: Connect QGroundControl

#### First Time Setup

1. **Launch QGroundControl**

2. **Navigate to Application Settings**

   - Click the "Q" icon (top left)
   - Select "Application Settings"
   - Select "Comm Links" tab

3. **Add New Connection**

   - Click "Add" at the bottom
   - Configure the connection:
     - **Name**: `ArduPilot SITL` (or any descriptive name)
     - **Type**: `UDP`
     - **Listening Port**: `14550`
     - **Server Addresses**: (leave empty)
   - Click "OK"

4. **Connect**
   - Select your new connection from the list
   - Click "Connect"

#### Subsequent Connections

QGroundControl will remember your connection. Simply:

1. Launch QGroundControl
2. It should auto-connect to SITL
3. If not, manually select the connection and click "Connect"

### Step 5: Verify Connection

Within 5 seconds of connecting, you should see:

- **Vehicle indicator** in top toolbar (shows "Copter" or "Plane")
- **GPS status** showing "GPS Lock" with satellite count
- **Battery percentage** (should show 100%)
- **Flight mode** (typically "STABILIZE" for copter, "MANUAL" for plane)
- **Telemetry streaming** in the lower status bar

**Visual confirmation checklist**:

```PlainText
✅ Vehicle icon is colored (not grayed out)
✅ GPS shows 3D lock with >10 satellites
✅ Battery shows 100%
✅ Compass heading is displayed
✅ Altitude shows ~0m
✅ No red warning banners (yellow warnings are OK)
```

### Step 6: Verify MAVLink Communication

You can verify MAVLink messages are flowing by checking the Docker logs:

```bash
# In another terminal
docker compose --profile copter logs -f
```

You should see periodic output like:

```PlainText
AP: GLOBAL_POSITION_INT
AP: ATTITUDE
AP: SYS_STATUS
```

These are MAVLink messages being sent from ArduPilot to MAVProxy.

## What You Have Now

At this point, you have a fully functional MAVLink system:

- **ArduPilot SITL** running in Docker, simulating a vehicle
- **MAVProxy** routing MAVLink messages over UDP
- **QGroundControl** connected and receiving telemetry
- **Heartbeat messages** flowing at 1Hz
- **Position telemetry** streaming (GLOBAL_POSITION_INT, ATTITUDE)
- **System status** being reported (SYS_STATUS, BATTERY_STATUS)

## Quick Test: Arm the Vehicle

Let's verify commands work by arming the vehicle:

### For Copter

1. In QGroundControl, ensure you're in **"Fly" view** (main screen)
2. The vehicle should be on the ground (altitude ~0m)
3. Click **"Ready to Fly"** slider to change mode to **"GUIDED"**
4. Click **"Arm"** button (or "Slide to Arm" depending on QGC version)

**Expected result**:

- Vehicle arms successfully
- Status changes to "Armed"
- Motors would spin up (in simulation, just shows "Armed" status)

**If arming fails**, check Docker logs for PreArm errors. Common issues:

- "PreArm: Need 3D Fix" - Wait 10 more seconds for GPS lock
- "PreArm: Compass not calibrated" - This can be ignored in SITL

### For Plane

1. Switch to **"MANUAL"** mode (planes don't require GPS lock to arm in MANUAL)
2. Click **"Arm"**

**Expected result**:

- Vehicle arms successfully
- Propeller would spin (simulated)

## Uploading a Simple Mission

1. In QGroundControl, switch to **"Plan" view**
2. Click **"File"** > **"New Plan"** to clear any existing waypoints
3. Click on the map to add 3-4 waypoints forming a simple path
4. Click **"Upload"** button to send the mission to the vehicle
5. Return to **"Fly" view**
6. Ensure vehicle is in **"AUTO"** mode
7. Arm the vehicle and the mission will start automatically

**Expected result**:

- Mission uploads successfully
- Vehicle navigates to each waypoint in sequence
- Current waypoint indicator updates in QGC
- Vehicle returns to home after completing the mission

## Stopping the Simulation

To stop the SITL:

```bash
# Press Ctrl+C in the terminal running docker compose
# OR in another terminal:
docker compose --profile copter down
```

## Troubleshooting

### Docker Build Fails

**Problem**: Build fails with network errors or Git clone timeouts.

**Solution**:

```bash
# Retry the build
docker compose build --no-cache

# If using corporate network, check proxy settings
# Add to docker-compose.yml under build args:
args:
  - HTTP_PROXY=http://proxy.company.com:8080
  - HTTPS_PROXY=http://proxy.company.com:8080
```

### Container Starts But No MAVProxy Output

**Problem**: Container runs but no "MAVProxy is running" message appears.

**Solution**:

```bash
# Check container logs
docker compose --profile copter logs

# Ensure you're using the correct profile
docker compose --profile copter up  # NOT just "docker compose up"
```

### QGroundControl Won't Connect

**Problem**: QGC shows "Disconnected" or "Waiting for vehicle".

**Solutions**:

1. **Verify SITL is running**:

```bash
   docker compose ps
   # Should show container as "Up"
```

2. **Check port availability**:

```bash
   # macOS/Linux
   lsof -i :14550

   # Windows
   netstat -ano | findstr :14550
```

If port is in use, another application is blocking it.

3. **Verify host.docker.internal resolves**:

```bash
   # Inside container
   docker compose exec ardupilot-copter ping -c 3 host.docker.internal
```

If this fails, you're not using Docker Desktop. Use explicit host IP:

```yaml
# In docker-compose.yml, change:
- GCS_IP_1=host.docker.internal
# To your machine's IP:
- GCS_IP_1=192.168.1.XXX
```

4. **Check firewall**:
   - macOS: System Preferences > Security & Privacy > Firewall
   - Windows: Windows Defender Firewall > Allow an app
   - Ensure QGroundControl is allowed to receive UDP traffic

### Docker Desktop Not Running

**Problem**: `docker compose` commands fail with "Cannot connect to Docker daemon".

**Solution**:

- **macOS**: Launch Docker Desktop from Applications
- **Windows**: Launch Docker Desktop from Start menu
- **Linux**: `sudo systemctl start docker`

Wait for Docker to fully start (whale icon in system tray).

### Performance Issues

**Problem**: SITL runs slowly or stutters.

**Solutions**:

1. **Reduce speedup factor**: In docker-compose.yml, change `SPEEDUP=1` to `SPEEDUP=0.5`
2. **Increase Docker resources**: Docker Desktop > Settings > Resources > increase RAM/CPU
3. **Close other applications**: SITL can be CPU-intensive during build

### Mission Upload Fails

**Problem**: Mission upload to vehicle fails or times out.

**Solutions**:

1. **Verify vehicle is armed and in correct mode**:
   - Copter: GUIDED or AUTO mode
   - Plane: AUTO mode
2. **Check MAVLink connection**: Ensure telemetry is streaming in QGC
3. **Simplify mission**: Start with just 2-3 waypoints
4. **Check logs**: Look for mission-related errors in Docker logs

## Next Steps

Now that you have a working SITL, you can:

- Experiment with different flight modes
- Create more complex missions with loiter points
- Test RTL (Return to Launch) functionality
- Capture MAVLink traffic with Wireshark for analysis
- Connect multiple GCS applications simultaneously
- Test multi-vehicle coordination with the dual-plane profile

## MAVLink Message Reference

This SITL setup demonstrates common MAVLink messages used in UAV operations:

**Connection & Status** (1 Hz):

- HEARTBEAT (#0) - System health and state
- SYS_STATUS (#1) - Battery, sensors, communication
- SYSTEM_TIME (#2) - Timing synchronization

**Telemetry** (5-10 Hz):

- GLOBAL_POSITION_INT (#33) - GPS position, velocity, heading
- ATTITUDE (#30) - Roll, pitch, yaw orientation
- GPS_RAW_INT (#24) - Raw GPS data with accuracy metrics
- BATTERY_STATUS (#147) - Detailed battery information
- VFR_HUD (#74) - HUD display data

**Mission Management**:

- MISSION_COUNT (#44) - Number of waypoints
- MISSION_ITEM_INT (#73) - Individual waypoint data
- MISSION_ACK (#47) - Mission upload acknowledgment
- MISSION_CURRENT (#42) - Currently active waypoint
- MISSION_ITEM_REACHED (#46) - Waypoint reached notification

**Commands**:

- COMMAND_LONG (#76) - Send commands (ARM, TAKEOFF, etc.)
- COMMAND_ACK (#77) - Command acknowledgment
- SET_MODE (#11) - Change flight mode

For detailed MAVLink protocol documentation, see [MAVLink Developer Guide](https://mavlink.io/en/).
