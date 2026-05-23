#!/bin/bash
# install.sh - Linux Installer for Node-Based VFX Compositor

set -e

echo "--- Node-Based VFX Compositor Installer (Linux) ---"

# 1. Check for Rust
if ! command -v cargo &> /dev/null; then
    echo "[!] Rust not found. Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "[✓] Rust is already installed."
fi

# 2. Check for C++ Build Tools (essential for eframe/wgpu)
# Checking for common compilers on Debian/Ubuntu based systems
if ! command -v g++ &> /dev/null; then
    echo "[!] C++ build tools not found. Installing..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y build-essential
    elif command -v dnf &> /dev/null; then
        sudo dnf groupinstall "Development Tools"
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm base-devel
    else
        echo "[ERROR] Unsupported package manager. Please install build-essential or equivalent manually."
        exit 1
    fi
else
    echo "[✓] C++ build tools are already installed."
fi

# 3. Build the Project
echo "Building the project in release mode..."
cargo build --release

# 4. Final Message
echo "--------------------------------------------------"
echo "Installation complete!"
echo "Run the application with: ./target/release/node-based-visual-effects"
echo "--------------------------------------------------"
