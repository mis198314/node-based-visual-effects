# install.ps1 - Windows Installer for Node-Based VFX Compositor

Write-Host "--- Node-Based VFX Compositor Installer (Windows) ---" -ForegroundColor Cyan

# 1. Check for Rust
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Rust not found. Installing Rust toolchain..." -ForegroundColor Yellow
    $rustupInstaller = "$env:TEMP\rustup-init.exe"
    Invoke-WebRequest -Uri "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe" -OutFile $rustupInstaller
    Start-Process -FilePath $rustupInstaller -ArgumentList "-y" -Wait
    Remove-Item $rustupInstaller
    Write-Host "[!] Rust installed. Please RESTART your terminal to update PATH before running the build." -ForegroundColor Red
    exit
} else {
    Write-Host "[✓] Rust is already installed." -ForegroundColor Green
}

# 2. Check for Visual Studio Build Tools (C++ build tools)
# We check if 'cl' is available in the current path. 
# Note: This usually requires the 'Developer PowerShell' or 'vcvarsall.bat' to be run.
if (-not (Get-Command cl -ErrorAction SilentlyContinue)) {
    Write-Host "[!] C++ build tools (MSVC) not detected in current PATH." -ForegroundColor Yellow
    Write-Host "Please ensure you have installed the 'Desktop development with C++' workload via Visual Studio Installer."
    Write-Host "Download: https://visualstudio.microsoft.com/visual-cpp-build-tools/"
    Write-Host "Note: If installed, please run this script from the 'Developer PowerShell for VS'." -ForegroundColor Cyan
    # We don't exit here as some users might have it configured differently, but we warn them.
} else {
    Write-Host "[✓] C++ build tools are already installed." -ForegroundColor Green
}

# 3. Build the Project
Write-Host "Building the project in release mode..." -ForegroundColor Cyan
try {
    cargo build --release
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Installation complete!" -ForegroundColor Green
    Write-Host "Run the application with: .\target\release\node-based-visual-effects.exe" -ForegroundColor White
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
} catch {
    Write-Host "[ERROR] Build failed. Please ensure C++ build tools are installed and configured." -ForegroundColor Red
}
