# Windows Bootstrap Script (PowerShell)
# Usage: iex (irm https://raw.githubusercontent.com/nnosal/nix-dotfiles/main/bootstrap.ps1)

Write-Host "🚀 Ultimate Dotfiles Windows Bootstrap" -ForegroundColor Cyan

$DotfilesDir = "$HOME\dotfiles"

# 1. Install Winget (should be present on modern Windows, but check)
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Winget is required. Please install App Installer from Microsoft Store."
    exit 1
}

# 2. Install Mise (Task Runner)
if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
    Write-Host "📦 Installing Mise..."
    winget install jdx.mise --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    if (!(Get-Command mise -ErrorAction SilentlyContinue)) {
        Write-Host "Mise n'est pas dans le PATH. Installation échouée." -ForegroundColor Red
        exit 1
    }
}

# 3. Clone Repo
if (-not (Test-Path $DotfilesDir)) {
    Write-Host "📂 Cloning dotfiles..."
    git clone https://github.com/nnosal/nix-dotfiles.git $DotfilesDir
}

Set-Location $DotfilesDir

# 4. Install Dependencies
Write-Host "🔧 Installing dependencies via Mise..."
mise install

# 5. Apply Native Config (Winget apps)
Write-Host "💿 Installing Windows Apps..."
#mise run install

Write-Host "✅ Windows Bootstrap Complete!" -ForegroundColor Green
Write-Host "👉 Now, run 'wsl --install' to setup the Linux subsystem."
