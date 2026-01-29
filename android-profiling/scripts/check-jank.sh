#!/bin/bash
# Measure frame jank on Android device via ADB
# Usage: ./check-jank.sh [package_name] [duration_seconds] [device_serial]

set -e

PACKAGE="${1:-dk.mypreffy.app}"
DURATION="${2:-5}"
DEVICE="${3:-}"

# Check ADB connection
if ! adb devices | grep -q "device$"; then
    echo "Error: No Android device connected"
    echo "Run 'adb devices' to check connection"
    exit 1
fi

# Build ADB command with optional device serial
ADB_CMD="adb"
if [[ -n "$DEVICE" ]]; then
    ADB_CMD="adb -s $DEVICE"
elif [[ $(adb devices | grep -c "device$") -gt 1 ]]; then
    echo "Multiple devices connected. Specify device serial as 3rd argument."
    echo "Available devices:"
    adb devices -l | grep "device$"
    exit 1
fi

echo "=== Android Frame Profiling ==="
echo "Package: $PACKAGE"
echo ""

# Reset frame stats
echo "Resetting frame stats..."
$ADB_CMD shell dumpsys gfxinfo "$PACKAGE" reset > /dev/null 2>&1

echo "Perform interactions on device for $DURATION seconds..."
sleep "$DURATION"

echo ""
echo "=== Frame Stats ==="

# Get and parse gfxinfo
OUTPUT=$($ADB_CMD shell dumpsys gfxinfo "$PACKAGE")

# Extract key metrics
echo "$OUTPUT" | grep -E "(Total frames rendered|Janky frames|Number Missed Vsync|Number High input latency|50th percentile|90th percentile|95th percentile|99th percentile)" | head -20

echo ""
echo "=== Summary ==="

# Parse janky frame percentage
TOTAL=$(echo "$OUTPUT" | grep "Total frames rendered" | head -1 | sed 's/[^0-9]//g')
JANKY=$(echo "$OUTPUT" | grep "Janky frames:" | head -1 | sed 's/.*: \([0-9]*\).*/\1/')

if [[ -n "$TOTAL" && -n "$JANKY" && "$TOTAL" -gt 0 ]]; then
    PERCENT=$((JANKY * 100 / TOTAL))
    echo "Janky: $JANKY / $TOTAL frames ($PERCENT%)"
    
    if [[ $PERCENT -gt 10 ]]; then
        echo "⚠️  High jank detected (>10%)"
    elif [[ $PERCENT -gt 5 ]]; then
        echo "⚡ Moderate jank (5-10%)"
    else
        echo "✓ Good performance (<5% jank)"
    fi
else
    echo "Could not parse frame stats. App may not be running."
fi
