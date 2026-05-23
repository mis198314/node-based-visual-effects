#!/bin/bash
# install-macos.sh - macOS Installer for Node-Based VFX Compositor

set -e

echo "--- Node-Based VFX Compositor Installer (macOS) ---"

# 1. Check for Rust
if ! command -v cargo &> /dev/null; then
    echo "[!] Rust not found. Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "[✓] Rust is already installed."
fi

# 2. Check for Xcode Command Line Tools (C++ build tools)
if ! xcode-select -p &> /dev/null; then
    echo "[!] Xcode Command Line Tools not found. Installing..."
    xcode-select --install
    echo "Please follow the prompt to install Xcode tools, then rerun this script."
    exit 1
else
    echo "[✓] Xcode Command Line Tools are already installed."
fi

# 3. Build the Project
echo "Building the project in release mode..."
cargo build --release

echo "--------------------------------------------------"
echo "Installation complete!"
echo "Run the application with: ./target/release/node-based-visual-effects"
echo "--------------------------------------------------"
