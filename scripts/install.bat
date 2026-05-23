@echo off
:: install.bat - Windows Installer for Node-Based VFX Compositor
setlocal enabledelayedexpansion

echo --- Node-Based VFX Compositor Installer (Windows) ---

:: 1. Check for Rust
where cargo >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [!] Rust not found. Installing Rust toolchain...
    powershell -Command "Invoke-WebRequest -Uri https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe -OutFile rustup-init.exe"
    start /wait rustup-init.exe -y
    del rustup-init.exe
    echo [!] Please restart your terminal to update PATH.
    pause
    exit /b
) else (
    echo [V] Rust is already installed.
)

:: 2. Check for Visual Studio Build Tools (C++ build tools)
:: We check for cl.exe (the MSVC compiler)
where cl >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [!] C++ build tools (MSVC) not found. 
    echo Please install the 'Desktop development with C++' workload via the Visual Studio Installer.
    echo https://visualstudio.microsoft.com/visual-cpp-build-tools/
    echo.
    echo This step cannot be fully automated without the VS Installer CLI.
    pause
    exit /b
) else (
    echo [V] C++ build tools are already installed.
)

:: 3. Build the Project
echo Building the project in release mode...
cargo build --release

echo --------------------------------------------------
echo Installation complete!
echo Run the application with: .\target\release\node-based-visual-effects.exe
echo --------------------------------------------------
pause
