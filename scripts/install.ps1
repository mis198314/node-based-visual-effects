# install.ps1 - Windows Installer for Node-Based VFX Compositor

Write-Host "--- Node-Based VFX Compositor Installer (Windows) ---" -ForegroundColor Cyan

# 0. Check for Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Git not found. Installing Git via Winget..." -ForegroundColor Yellow
    try {
        winget install --id Git.Git -e --source winget
        Write-Host "[✓] Git installed. PLEASE RESTART YOUR TERMINAL before running this script again to update PATH." -ForegroundColor Red
        exit
    } catch {
        Write-Host "[ERROR] Winget failed to install Git. Please install Git manually from https://git-scm.com/" -ForegroundColor Red
        exit
    }
}

# 1. Clone the Repository
$RepoUrl = "https://github.com/mis198314/node-based-visual-effects.git"
$InstallDir = "$HOME\node-based-visual-effects"

Write-Host "Checking repository status..." -ForegroundColor Cyan
if (-not (Test-Path $InstallDir)) {
    Write-Host "Cloning repository to $InstallDir..." -ForegroundColor Cyan
    try {
        git clone $RepoUrl $InstallDir
    } catch {
        Write-Host "[ERROR] Git clone failed. Please check your internet connection or repository URL." -ForegroundColor Red
        exit
    }
} else {
    Write-Host "[✓] Repository already exists at $InstallDir. Updating..." -ForegroundColor Green
    Set-Location $InstallDir
    try {
        git pull
    } catch {
        Write-Host "[!] Git pull failed. You may have local changes. Attempting to continue..." -ForegroundColor Yellow
    }
}
Set-Location $InstallDir

# 2. Check for Rust
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Rust not found. Installing Rust toolchain..." -ForegroundColor Yellow
    $rustupInstaller = "$env:TEMP\rustup-init.exe"
    Invoke-WebRequest -Uri "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe" -OutFile $rustupInstaller
    Start-Process -FilePath $rustupInstaller -ArgumentList "-y" -Wait
    Remove-Item $rustupInstaller
    Write-Host "[!] Rust installed. PLEASE RESTART YOUR TERMINAL to update PATH before running the build." -ForegroundColor Red
    exit
} else {
    Write-Host "[✓] Rust is already installed." -ForegroundColor Green
}

# 3. Check for Visual Studio Build Tools (C++ build tools)
if (-not (Get-Command cl -ErrorAction SilentlyContinue)) {
    Write-Host "[!] C++ build tools (MSVC) not detected in current PATH." -ForegroundColor Yellow
    Write-Host "Please ensure you have installed the 'Desktop development with C++' workload via Visual Studio Installer."
    Write-Host "Download: https://visualstudio.microsoft.com/visual-cpp-build-tools/"
    Write-Host "Note: If installed, please run this script from the 'Developer PowerShell for VS'." -ForegroundColor Cyan
} else {
    Write-Host "[✓] C++ build tools are already installed." -ForegroundColor Green
}

# 4. Build the Project
Write-Host "Building the project in release mode..." -ForegroundColor Cyan
try {
    cargo build --release
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Installation complete!" -ForegroundColor Green
    Write-Host "Binary location: $InstallDir\target\release\node-based-visual-effects.exe"
    Write-Host "Run it with: & '$InstallDir\target\release\node-based-visual-effects.exe'" -ForegroundColor White
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
} catch {
    Write-Host "[ERROR] Build failed. Please ensure C++ build tools are installed and configured." -ForegroundColor Red
}
