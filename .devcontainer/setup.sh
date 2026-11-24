#!/usr/bin/env bash
# Installs what the demos need on Ubuntu 24.04: a C/C++ toolchain, ninja,
# GoogleTest, meson 1.6 or later, and GitHub Copilot CLI.
set -euo pipefail

SUDO=""
if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; fi
export DEBIAN_FRONTEND=noninteractive

$SUDO apt-get update -y
$SUDO apt-get install -y --no-install-recommends \
  build-essential ninja-build pkg-config cmake python3-venv \
  libgtest-dev libgmock-dev git curl ca-certificates

# Ubuntu ships an older meson; libpldm needs 1.6 or later.
if ! meson --version 2>/dev/null | grep -Eq '^(1\.([6-9]|[1-9][0-9])|[2-9])\.'; then
  $SUDO python3 -m venv /opt/meson
  $SUDO /opt/meson/bin/pip install --quiet --upgrade 'meson>=1.6'
  $SUDO ln -sf /opt/meson/bin/meson /usr/local/bin/meson
fi

if [ "${INSTALL_COPILOT_CLI:-1}" = "1" ] && ! command -v copilot >/dev/null 2>&1; then
  curl -fsSL https://gh.io/copilot-install | $SUDO bash
fi

echo "meson $(meson --version)"
if command -v copilot >/dev/null 2>&1; then copilot --version | head -1; fi
