# Audio-to-JSON Alignment Tool - PowerShell Script

param(
    [Parameter(Position=0)]
    [string]$Command,
    [Parameter(Position=1)]
    [string]$File
)

function Show-Help {
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║        Audio-to-JSON Alignment Tool                    ║" -ForegroundColor Blue
    Write-Host "║        Word-level timing using Whisper                 ║" -ForegroundColor Blue
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Quick Start:" -ForegroundColor Green
    Write-Host "  .\run.ps1 install              - Setup Docker container"
    Write-Host "  .\run.ps1 align audio.mp3      - Process audio file"
    Write-Host "  .\run.ps1 clean                - Remove everything"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Green
    Write-Host "  .\run.ps1 align podcast.mp3"
    Write-Host "  .\run.ps1 align inputs\interview.wav"
    Write-Host ""
    Write-Host "Output:" -ForegroundColor Yellow -NoNewline
    Write-Host " Files saved to outputs\<filename>.json"
}

function Install-Tool {
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║  ONE-CLICK INSTALLER                                   ║" -ForegroundColor Blue
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Checking for Docker..." -ForegroundColor Yellow

    if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: Docker not found. Please install Docker Desktop first." -ForegroundColor Red
        Write-Host "Visit: https://docs.docker.com/desktop/install/windows-install/"
        exit 1
    }

    Write-Host "Docker found - Building container..." -ForegroundColor Green
    Write-Host ""
    docker-compose build
    Write-Host ""
    Write-Host "Setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow -NoNewline
    Write-Host " .\run.ps1 align your_audio.mp3"
}

function Align-Audio {
    if ([string]::IsNullOrEmpty($File)) {
        Write-Host "ERROR: Please specify audio file" -ForegroundColor Red
        Write-Host "Example: .\run.ps1 align audio.mp3"
        exit 1
    }

    if (!(Test-Path $File)) {
        Write-Host "ERROR: File not found: $File" -ForegroundColor Red
        exit 1
    }

    Write-Host "Running alignment on $File..." -ForegroundColor Blue
    docker-compose run --rm audio_align python app.py align "$File"
    Write-Host ""
    Write-Host "Alignment complete!" -ForegroundColor Green
    $filename = [System.IO.Path]::GetFileNameWithoutExtension($File)
    Write-Host "Output saved to:" -ForegroundColor Blue -NoNewline
    Write-Host " outputs\$filename.json"
}

function Clean-All {
    Write-Host "Cleaning up everything..." -ForegroundColor Blue
    Write-Host "Removing generated files..." -ForegroundColor Yellow

    if (Test-Path "outputs\*.json") { Remove-Item "outputs\*.json" -Force }
    if (Test-Path "__pycache__") { Remove-Item "__pycache__" -Recurse -Force }
    if (Test-Path "utils\__pycache__") { Remove-Item "utils\__pycache__" -Recurse -Force }

    Write-Host "Removing Docker containers and images..." -ForegroundColor Yellow
    docker-compose down --rmi all --volumes
    docker system prune -f

    Write-Host "Cleanup complete!" -ForegroundColor Green
}

# Main
switch ($Command) {
    "help" { Show-Help }
    "install" { Install-Tool }
    "align" { Align-Audio }
    "clean" { Clean-All }
    default { Show-Help }
}
