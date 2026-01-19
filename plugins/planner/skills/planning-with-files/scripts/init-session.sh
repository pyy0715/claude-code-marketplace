#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/../templates"

generate_plan_name() {
    local description="$1"
    echo "$description" | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9가-힣]/-/g' | \
        sed 's/--*/-/g' | \
        sed 's/^-//;s/-$//' | \
        cut -c1-50
}

INPUT="$1"
DATE=$(date +%Y-%m-%d)

if [ -z "$INPUT" ]; then
    echo "Usage: init-session.sh <task-description>"
    exit 1
fi

if echo "$INPUT" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    PLAN_NAME="$INPUT"
else
    PLAN_NAME=$(generate_plan_name "$INPUT")
fi

PLAN_DIR="docs/${PLAN_NAME}"

if [ -d "$PLAN_DIR" ]; then
    echo "Plan directory already exists: $PLAN_DIR"
    exit 0
fi

mkdir -p "$PLAN_DIR"

sed -e "s/\[작업 이름\]/$INPUT/g" \
    -e "s/\[날짜\]/$DATE/g" \
    "${TEMPLATE_DIR}/task_plan.md" > "${PLAN_DIR}/task_plan.md"

sed -e "s/\[작업 이름\]/$INPUT/g" \
    "${TEMPLATE_DIR}/findings.md" > "${PLAN_DIR}/findings.md"

sed -e "s/\[작업 이름\]/$INPUT/g" \
    -e "s/\[날짜\]/$DATE/g" \
    "${TEMPLATE_DIR}/progress.md" > "${PLAN_DIR}/progress.md"

echo "Initialized: $PLAN_DIR/"
echo "  - task_plan.md"
echo "  - findings.md"
echo "  - progress.md"
