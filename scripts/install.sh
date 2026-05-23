#!/bin/bash
# install.sh - Linux Installer for Node-Based VFX Compositor

set -e

echo "--- Node-Based VFX Compositor Installer (Linux) ---"

# 0. Check for Git
if ! command -v git &> /dev/null; then
    echo "[!] Git not found. Installing Git..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y git
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm git
    else
        echo "[ERROR] Could not install Git automatically. Please install it manually."
        exit 1
    fi
    # Refresh shell command cache
    hash -r
fi

# 1. Clone the Repository
REPO_URL="https://github.com/mis198314/node-based-visual-effects.git"
INSTALL_DIR="$HOME/node-based-visual-effects"

echo "Checking repository status..."
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Cloning repository to $INSTALL_DIR..."
    if ! git clone "$REPO_URL" "$INSTALL_DIR"; then
        echo "[ERROR] Git clone failed. Please check your internet connection or repository URL."
        exit 1
    fi
else
    echo "[✓] Repository already exists at $INSTALL_DIR. Updating..."
    cd "$INSTALL_DIR"
    if ! git pull; then
        echo "[!] Git pull failed. You may have local changes. Attempting to continue..."
    fi
fi
cd "$INSTALL_DIR"

# 2. Check for Rust
if ! command -v cargo &> /dev/null; then
    echo "[!] Rust not found. Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "[✓] Rust is already installed."
fi

# 3. Check for C++ Build Tools
if ! command -v g++ &> /dev/null; then
    echo "[!] C++ build tools not found. Installing..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y build-essential
    elif command -v dnf &> /dev/null; then
        sudo dnf groupinstall "Development Tools" -y
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm base-devel
    else
        echo "[ERROR] Unsupported package manager. Please install build-essential manually."
        exit 1
    fi
else
    echo "[✓] C++ build tools are already installed."
fi

# 4. Build the Project
echo "Building the project in release mode..."
if ! cargo build --release; then
    echo "[ERROR] Build failed. Please ensure all prerequisites are installed."
    exit 1
fi

echo "--------------------------------------------------"
echo "Installation complete!"
echo "Binary location: $INSTALL_DIR/target/release/node-based-visual-effects"
echo "Run it with: $INSTALL_DIR/target/release/node-based-visual-effects"
echo "--------------------------------------------------"
