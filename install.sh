#!/usr/bin/env bash
# Archexa installer — downloads the latest release binary for your platform.
# Usage: curl -fsSL https://raw.githubusercontent.com/ereshzealous/archexa/refs/heads/main/install.sh | bash
set -euo pipefail

APP="archexa"
REPO="ereshzealous/archexa"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

# ── Detect platform ──────────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin)
    case "$ARCH" in
      arm64)  PLATFORM="macos-arm64" ;;
      x86_64) PLATFORM="macos-x86_64" ;;
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
mkdir -p "$INSTALL_DIR"
mv "$TMP" "${INSTALL_DIR}/${APP}"

echo ""
echo "${APP} ${TAG} installed to ${INSTALL_DIR}/${APP}"

# ── Check PATH ────────────────────────────────────────────────────────
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
  echo ""
  echo "NOTE: ${INSTALL_DIR} is not in your PATH."
  echo "Add it by running:  export PATH=\"${INSTALL_DIR}:\$PATH\""
  echo "To make it permanent, add the line above to your ~/.bashrc or ~/.zshrc"
else
  echo "Run '${APP} --help' to get started."
fi
