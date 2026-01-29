---
name: performance-testing
description: Runs Maestro UI tests with Android frame profiling to measure scroll performance. Use when comparing before/after performance or recording demo videos with jank metrics.
---

# Performance Testing

Combine Maestro UI automation with Android frame profiling to measure and compare scroll performance.

## Quick Start

```bash
# 1. Ensure Android device is connected
adb devices

# 2. Reset frame stats
adb shell dumpsys gfxinfo dk.mypreffy.app reset

# 3. Run Maestro scroll demo
maestro test .maestro/scroll-demo.yaml

# 4. Capture frame stats
adb shell dumpsys gfxinfo dk.mypreffy.app | grep -E "(Total frames|Janky|percentile)"
```

## Full Performance Comparison Workflow

### Before Changes (Production Build)

```bash
# Reset stats
adb shell dumpsys gfxinfo dk.mypreffy.app reset

# Run test and record video
maestro test .maestro/scroll-demo-before.yaml --output tmp/home-scroll-before.mp4

# Capture stats
adb shell dumpsys gfxinfo dk.mypreffy.app > tmp/frame-stats-before.txt
```

### After Changes (Development Build)

```bash
# Reset stats
adb shell dumpsys gfxinfo dk.mypreffy.app reset

# Run test and record video
maestro test .maestro/scroll-demo.yaml --output tmp/home-scroll-after.mp4

# Capture stats
adb shell dumpsys gfxinfo dk.mypreffy.app > tmp/frame-stats-after.txt
```

### Compare Results

```bash
# Quick comparison
echo "=== BEFORE ===" && grep -E "(Janky|90th)" tmp/frame-stats-before.txt
echo "=== AFTER ===" && grep -E "(Janky|90th)" tmp/frame-stats-after.txt
```

## Automated Script

Run the full comparison workflow:

```bash
./scripts/perf-compare.sh
```

## Key Metrics

| Metric | Good | Concerning |
|--------|------|------------|
| Janky frames | <5% | >10% |
| 90th percentile | <16ms | >20ms |
| 99th percentile | <32ms | >50ms |

## Related Skills

- **maestro-testing** - Maestro flow details and commands
- **android-profiling** - Frame profiling deep dive

## Available Flows

| Flow | Use Case |
|------|----------|
| `scroll-demo.yaml` | Development builds with testIDs |
| `scroll-demo-before.yaml` | Production builds (text matching) |

## Device Setup

Ensure an Android device is connected via USB or ADB over network:

```bash
adb devices
```
