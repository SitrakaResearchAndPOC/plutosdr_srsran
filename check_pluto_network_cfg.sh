#!/bin/bash

CFG="$1"

echo "[INFO] Starting Pluto config check..."

# ---------------------------
# 0. FILE CHECK (FIRST)
# ---------------------------
if [ ! -f "$CFG" ]; then
    echo "[ERROR] CFG not found: $CFG"
    exit 1
fi

echo "[INFO] CFG found"

# ---------------------------
# 1. Pluto hostname
# ---------------------------
NAME="${NAME_PLUTO:-}"

# Remove all spaces
NAME=$(echo "$NAME" | tr -d '[:space:]')

# Default hostname
if [ -z "$NAME" ]; then
    NAME="pluto"
    echo "[INFO] NAME_PLUTO not defined, using default: $NAME"
fi

URI="${NAME}.local"

echo "[INFO] Pluto hostname = $NAME"
echo "[INFO] Pluto URI = ip:$URI"

# ---------------------------
# 2. Detect RF line
# ---------------------------
LINE=$(grep -E "^[[:space:]]*(dev-args|device_args|rf\.stream_args)" "$CFG")

if [ -z "$LINE" ]; then
    echo "[ERROR] No RF args line found"
    exit 1
fi

echo "[INFO] RF line detected:"
echo "[OLD_CONF] $LINE"

# ---------------------------
# 3. Skip if already configured
# ---------------------------
if echo "$LINE" | grep -q "uri=ip:"; then
    echo "[INFO] uri=ip already present, no change"
    exit 0
fi

# ---------------------------
# 4. Patch config
# ---------------------------
echo "[INFO] Adding uri=ip:$URI"

sed -i "s|^\([[:space:]]*dev-args.*\)$|\1,uri=ip:$URI|" "$CFG"
sed -i "s|^\([[:space:]]*device_args.*\)$|\1,uri=ip:$URI|" "$CFG"
sed -i "s|^\([[:space:]]*rf\.stream_args.*\)$|\1,uri=ip:$URI|" "$CFG"

# ---------------------------
# 5. Verify
# ---------------------------
if grep -q "uri=ip:$URI" "$CFG"; then
    echo "[INFO] SUCCESS: uri added"
else
    echo "[ERROR] Patch failed"
    exit 1
fi

echo "[INFO] DONE"

# ---------------------------
# 6. ReDetect RF line
# ---------------------------
LINE=$(grep -E "^[[:space:]]*(dev-args|device_args|rf\.stream_args)" "$CFG")

if [ -z "$LINE" ]; then
    echo "[ERROR] No RF args line found"
    exit 1
fi

echo "[INFO] RF line detected:"
echo "[NEW_CONF] $LINE"
