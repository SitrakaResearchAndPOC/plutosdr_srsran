#!/bin/bash

CFG="$1"

echo "[INFO] Starting Pluto config cleanup..."
# ---------------------------
# 1. Detect RF line
# ---------------------------
LINE=$(grep -E "^[[:space:]]*(dev-args|device_args|rf\.stream_args)" "$CFG")

if [ -z "$LINE" ]; then
    echo "[ERROR] No RF args line found"
    exit 1
fi

echo "[INFO] RF line detected:"
echo "[OLD_CONF] $LINE"


# ---------------------------
# 2. Check file
# ---------------------------
if [ ! -f "$CFG" ]; then
    echo "[ERROR] CFG not found: $CFG"
    exit 1
fi

echo "[INFO] CFG found"

# ---------------------------
# 3. Check if uri exists
# ---------------------------
if ! grep -q "uri=ip:" "$CFG"; then
    echo "[INFO] No uri=ip found - nothing to do"
    exit 0
fi

echo "[INFO] Removing Pluto URI from RF line(s)"

# ---------------------------
# 4. Remove uri=ip:<hostname>.local
# ---------------------------
sed -i -E 's/,?uri=ip:[^,[:space:]]+\.local//g' "$CFG"


# ---------------------------
# 5. Verification
# ---------------------------
if grep -q "uri=ip:" "$CFG"; then
    echo "[ERROR] Removal failed"
    exit 1
fi

# ---------------------------
# 6. Detect RF line
# ---------------------------
LINE=$(grep -E "^[[:space:]]*(dev-args|device_args|rf\.stream_args)" "$CFG")

if [ -z "$LINE" ]; then
    echo "[ERROR] No RF args line found"
    exit 1
fi

echo "[INFO] RF line detected:"
echo "[NEW_CONF] $LINE"


echo "[INFO] Cleanup successful"
