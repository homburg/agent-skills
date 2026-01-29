---
name: android-profiling
description: Detects React Native stutters and frame drops on Android via ADB. Use when profiling performance, checking for jank, or measuring FPS.
---

# Android Profiling

Detect stutters, frame drops, and performance issues on a connected Android device via ADB.

## Prerequisites

- Android device connected via USB with USB debugging enabled
- ADB installed and device visible in `adb devices`

## Quick Frame Stats

```bash
# Get frame rendering stats (janky frames, percentiles)
adb shell dumpsys gfxinfo <package_name>

# Reset stats before measuring
adb shell dumpsys gfxinfo <package_name> reset

# Example for this app
adb shell dumpsys gfxinfo dk.mypreffy.app reset
adb shell dumpsys gfxinfo dk.mypreffy.app
```

## Automated Stutter Detection

Run `scripts/check-jank.sh` to measure frame stats:

```bash
# Reset, wait for interaction, then report jank
./scripts/check-jank.sh dk.mypreffy.app
```

## Key Metrics to Watch

From `dumpsys gfxinfo` output:

- **Janky frames** - Frames that took >16ms to render
- **Total frames rendered** - Total frame count
- **90th/95th/99th percentile** - Frame render times
- **Number Missed Vsync** - Missed vertical sync events
- **Number High input latency** - Input processing delays

## Interpreting Results

| Metric | Good | Concerning |
|--------|------|------------|
| Janky frames | <5% of total | >10% of total |
| 90th percentile | <16ms | >20ms |
| 99th percentile | <32ms | >50ms |

## React Native Threads

When using System Tracing, look for these threads:

- **UI Thread** (package name) - Android measure/layout/draw
- **mqt_js** - JavaScript execution
- **mqt_native_modules** - Native module calls
- **RenderThread** - OpenGL commands (Android 5+)

If JS thread crosses 16ms frame boundaries → JS bottleneck
If UI/Render thread crosses boundaries → Native rendering bottleneck

## Continuous Monitoring

```bash
# Watch frame stats in real-time (requires interaction)
while true; do
  adb shell dumpsys gfxinfo dk.mypreffy.app | grep -E "(Janky|percentile)"
  sleep 2
done
```

## Triggering Dev Menu

```bash
# Open React Native dev menu on device
adb shell input keyevent 82

# Then enable "Show Perf Monitor" for on-device FPS overlay
```
