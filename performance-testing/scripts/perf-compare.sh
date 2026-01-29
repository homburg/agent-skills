#!/bin/bash
# Performance comparison: run Maestro tests with frame profiling
# Usage: ./perf-compare.sh [before|after|both]

set -e

PACKAGE="dk.mypreffy.app"
OUTPUT_DIR="tmp"
MODE="${1:-both}"

mkdir -p "$OUTPUT_DIR"

run_test() {
    local label="$1"
    local flow="$2"
    local video="$OUTPUT_DIR/home-scroll-${label}.mp4"
    local stats="$OUTPUT_DIR/frame-stats-${label}.txt"

    echo "=== Running $label test ==="
    
    # Reset frame stats
    adb shell dumpsys gfxinfo "$PACKAGE" reset > /dev/null 2>&1
    
    # Run Maestro test with recording
    if maestro test ".maestro/$flow" --output "$video"; then
        echo "Video saved: $video"
    else
        echo "Maestro test failed, continuing to capture stats..."
    fi
    
    # Capture frame stats
    adb shell dumpsys gfxinfo "$PACKAGE" > "$stats"
    echo "Stats saved: $stats"
    
    # Print summary
    echo ""
    echo "=== $label Results ==="
    grep -E "(Total frames rendered|Janky frames|90th percentile|95th percentile|99th percentile)" "$stats" | head -10
    echo ""
}

case "$MODE" in
    before)
        run_test "before" "scroll-demo-before.yaml"
        ;;
    after)
        run_test "after" "scroll-demo.yaml"
        ;;
    both)
        run_test "before" "scroll-demo-before.yaml"
        echo "Press Enter to run 'after' test (switch to dev build if needed)..."
        read -r
        run_test "after" "scroll-demo.yaml"
        
        echo "=== COMPARISON ==="
        echo ""
        echo "BEFORE:"
        grep "Janky frames" "$OUTPUT_DIR/frame-stats-before.txt" | head -1
        echo ""
        echo "AFTER:"
        grep "Janky frames" "$OUTPUT_DIR/frame-stats-after.txt" | head -1
        ;;
    *)
        echo "Usage: $0 [before|after|both]"
        exit 1
        ;;
esac

echo ""
echo "Done! Videos and stats saved to $OUTPUT_DIR/"
