#!/usr/bin/env bash
# Archexa installer — downloads the latest release binary for your platform.
# Usage: curl -fsSL https://raw.githubusercontent.com/ereshzealous/archexa/main/install.sh | bash
set -euo pipefail

APP="archexa"
REPO="ereshzealous/archexa"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# ── Detect platform ──────────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin)
    case "$ARCH" in
      arm64)  PLATFORM="macos-arm64" ;;
      x86_64) PLATFORM="macos-arm64" ;;  # Intel Macs run ARM binary via Rosetta 2
      *)      echo "Unsupported macOS architecture: $ARCH"; exit 1 ;;
    esac
    ;;
  Linux)
    case "$ARCH" in
      x86_64|amd64) PLATFORM="linux-x86_64" ;;
      aarch64|arm64) PLATFORM="linux-arm64" ;;
      *)      echo "Unsupported Linux architecture: $ARCH"; exit 1 ;;
    esac
    ;;
  *)
    echo "Unsupported OS: $OS (use Windows installer or download manually)"
    exit 1
    ;;
esac

BINARY="${APP}-${PLATFORM}"

# ── Find latest release ──────────────────────────────────────────────
echo "Detecting latest release..."
TAG=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep '"tag_name"' | head -1 | cut -d'"' -f4)

if [ -z "$TAG" ]; then
  echo "Could not determine latest release. Check https://github.com/${REPO}/releases"
  exit 1
fi

URL="https://github.com/${REPO}/releases/download/${TAG}/${BINARY}"
echo "Downloading ${APP} ${TAG} for ${PLATFORM}..."

# ── Download ──────────────────────────────────────────────────────────
TMP=$(mktemp)
if ! curl -fsSL -o "$TMP" "$URL"; then
  echo "Download failed. Check if release exists: ${URL}"
  rm -f "$TMP"
  exit 1
fi

chmod +x "$TMP"

# ── macOS: Remove quarantine attribute ────────────────────────────────
if [ "$OS" = "Darwin" ]; then
  xattr -d com.apple.quarantine "$TMP" 2>/dev/null || true
fi

# ── Install ───────────────────────────────────────────────────────────
if [ -w "$INSTALL_DIR" ]; then
  mv "$TMP" "${INSTALL_DIR}/${APP}"
else
  echo "Installing to ${INSTALL_DIR} (requires sudo)..."
  sudo mv "$TMP" "${INSTALL_DIR}/${APP}"
fi

echo ""
echo "${APP} ${TAG} installed to ${INSTALL_DIR}/${APP}"
echo "Run '${APP} --help' to get started."
