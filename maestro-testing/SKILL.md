---
name: maestro-testing
description: Runs Maestro UI tests and records demo videos for the mypreffy React Native app. Use when asked to run E2E tests, UI automation, or record scroll performance demos.
---

# Maestro Testing

Run Maestro UI automation tests and record demo videos for the mypreffy React Native app.

## Installation

```bash
# Install Maestro (if not already installed)
curl -Ls "https://get.maestro.mobile.dev" | bash
```

## Available Flows

All flows are in `.maestro/` directory:

| Flow | Description | Target |
|------|-------------|--------|
| `scroll-demo.yaml` | Home feed scroll performance demo with testIDs | Development builds |
| `scroll-demo-before.yaml` | Home feed scroll demo using text matching | Production builds |

## Running Tests

```bash
# Run a specific flow
maestro test .maestro/scroll-demo.yaml

# Run all flows in the directory
maestro test .maestro/

# Run with specific device
maestro --device <device-id> test .maestro/scroll-demo.yaml
```

## Recording Videos

### Using Maestro's Built-in Recording

```bash
# Record with local rendering (better quality)
maestro record --local .maestro/scroll-demo.yaml tmp/home-scroll-after.mp4
```

### Using ADB for Android

```bash
# Start recording in background (run in separate terminal)
adb shell screenrecord --bit-rate 8000000 /sdcard/home-scroll-demo.mp4

# Run Maestro test
maestro test .maestro/scroll-demo.yaml

# Stop recording with Ctrl+C, then pull the video
adb pull /sdcard/home-scroll-demo.mp4 ./tmp/
```

## Running on Specific Device

**Important:** Maestro does NOT use the `ANDROID_SERIAL` environment variable. You must use the `--device` flag.

```bash
# List connected devices
adb devices

# Run test on specific device (use device ID from adb devices)
maestro --device thomas-z-fold7-2026:5555 test .maestro/scroll-demo.yaml
```

## Writing Maestro Flows

### Basic Structure

```yaml
appId: dk.mypreffy.app
name: Flow Name
tags:
  - smoke
---

- launchApp:
    clearState: false
    clearKeychain: false
```

### Key Commands

```yaml
# Wait for element by testID
- extendedWaitUntil:
    visible:
      id: "home-feed-list"
    timeout: 15000

# Wait for element by text
- extendedWaitUntil:
    visible:
      text: "Find places, people, reviews"
    timeout: 15000

# Simple scroll (no parameters needed)
- scroll

# Directional swipe with duration
- swipe:
    direction: UP
    duration: 800

# Repeat commands
- repeat:
    times: 3
    commands:
      - swipe:
          direction: UP
          duration: 800

# Conditional execution
- runFlow:
    when:
      visible:
        id: "post-media-carousel-.*"
    commands:
      - swipe:
          direction: LEFT
          duration: 500

# Assert element is visible
- assertVisible:
    id: "post-card-.*"
```

### TestIDs Available

Elements with testIDs for development builds:
- `home-feed-list` - Home feed LegendList
- `post-card-{index}` - Post card at index (0, 1, 2...)
- `post-media-carousel-{index}` - Media carousel for posts with multiple items

### Text Matching (Production)

For production builds without testIDs, use text matching:
- `"Find places, people, reviews"` - Search placeholder
- `"Discover People"` - Discover section header

## Configuration

Workspace config in `.maestro/config.yaml`:
- Default timeout: 10000ms
- Test output: `tmp/maestro-output/`
- Animations disabled on both iOS and Android

## Performance Demo Workflow

1. **Before changes**: Run on production build
   ```bash
   maestro test .maestro/scroll-demo-before.yaml --output tmp/home-scroll-before.mp4
   ```

2. **After changes**: Run on development build with testIDs
   ```bash
   maestro test .maestro/scroll-demo.yaml --output tmp/home-scroll-after.mp4
   ```

3. Compare videos side-by-side for frame drops and jank
