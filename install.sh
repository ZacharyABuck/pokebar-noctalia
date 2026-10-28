#!/usr/bin/env bash
#
# PokeBar for Noctalia - installer
# Installs the pokebar CLI + sprite assets and links the plugin into Noctalia.
# License: MIT

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.config/pokebar"
BIN_DIR="${HOME}/.local/bin"
PLUGIN_DIR="${HOME}/.local/share/noctalia/plugins"

mkdir -p "${TARGET_DIR}/current" "${BIN_DIR}" "${PLUGIN_DIR}"

echo "[1/4] Copying sprite assets..."
cp -r "${REPO_DIR}/assets" "${TARGET_DIR}/"

echo "[2/4] Installing pokebar CLI to ${BIN_DIR}/pokebar..."
install -m 755 "${REPO_DIR}/bin/pokebar" "${BIN_DIR}/pokebar"

echo "[3/4] Setting default Pokemon (Pikachu Running)..."
"${BIN_DIR}/pokebar" set pikachu-run

echo "[4/4] Linking plugin into ${PLUGIN_DIR}/pokebar..."
ln -sfn "${REPO_DIR}" "${PLUGIN_DIR}/pokebar"

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "Note: ${BIN_DIR} is not in your PATH; add it to use 'pokebar' in a terminal."
fi

echo
echo "Done. Enable the plugin and add the widget to your bar:"
echo "  noctalia msg plugins enable pokebar/pokebar"
