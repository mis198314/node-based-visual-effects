#!/bin/bash
# install-macos.sh - macOS Installer for Node-Based VFX Compositor

set -e

echo "--- Node-Based VFX Compositor Installer (macOS) ---"

# 0. Check for Git
if ! command -v git &> /dev/null; then
    echo "[!] Git not found. Installing Git via Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "[!] Homebrew not found. Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install git
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
    # Just to be safe, ensure we have the latest toolchain
    rustup update
fi

# 3. Check for Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    echo "[!] Xcode Command Line Tools not found. Installing..."
    xcode-select --install
    echo "Please follow the prompt to install Xcode tools, then rerun this script."
    exit 1
else
    echo "[✓] Xcode Command Line Tools are already installed."
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
echo "Run it with: $INSTALL_DIR/target/release/node-visual-effects"
echo "--------------------------------------------------"
