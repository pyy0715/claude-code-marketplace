#!/bin/bash

PLAN_FILES=$(find docs/*/task_plan.md 2>/dev/null || true)

if [ -z "$PLAN_FILES" ]; then
    exit 0
fi

echo ""
echo "=== Task Completion Check ==="
echo ""

ALL_COMPLETE=true

while IFS= read -r PLAN_FILE; do
    [ -z "$PLAN_FILE" ] && continue

    PLAN_DIR=$(dirname "$PLAN_FILE")
    PLAN_NAME=$(basename "$PLAN_DIR")

    TOTAL=$(grep -c "^- \[" "$PLAN_FILE" 2>/dev/null || echo "0")
    COMPLETE=$(grep -c "^- \[x\]" "$PLAN_FILE" 2>/dev/null || echo "0")
    INCOMPLETE=$(grep -c "^- \[ \]" "$PLAN_FILE" 2>/dev/null || echo "0")

    if [ "$TOTAL" -eq 0 ]; then
        continue
    fi

    echo "Plan: $PLAN_NAME"
    echo "  Total:      $TOTAL"
    echo "  Complete:   $COMPLETE"
    echo "  Incomplete: $INCOMPLETE"

    if [ "$INCOMPLETE" -gt 0 ]; then
        ALL_COMPLETE=false
        echo "  Status:     IN PROGRESS"
    else
        echo "  Status:     COMPLETE"
    fi
    echo ""
done <<< "$PLAN_FILES"

if [ "$ALL_COMPLETE" = false ]; then
    echo "TASKS NOT COMPLETE"
    echo ""
    echo "Before stopping:"
    echo "  1. Complete current phases"
    echo "  2. Update task_plan.md"
    echo "  3. Log reason in progress.md"
    echo ""
    echo "Continue stopping? (y/n)"
    read -r response

    if [ "$response" != "y" ]; then
        exit 1
    fi
fi

echo "All tasks complete. Safe to stop."
exit 0
