@echo off
REM Audio-to-JSON Alignment Tool - Windows Batch Script

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="install" goto install
if "%1"=="align" goto align
if "%1"=="clean" goto clean
goto help

:help
echo ╔════════════════════════════════════════════════════════╗
echo ║        Audio-to-JSON Alignment Tool                    ║
echo ║        Word-level timing using Whisper                 ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo Quick Start:
echo   run.bat install              - Setup Docker container
echo   run.bat align audio.mp3      - Process audio file
echo   run.bat clean                - Remove everything
echo.
echo Examples:
echo   run.bat align podcast.mp3
echo   run.bat align inputs\interview.wav
echo.
echo Output: Files saved to outputs\^<filename^>.json
goto end

:install
echo ╔════════════════════════════════════════════════════════╗
echo ║  ONE-CLICK INSTALLER                                   ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo Checking for Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker not found. Please install Docker Desktop first.
    echo Visit: https://docs.docker.com/desktop/install/windows-install/
    exit /b 1
)
echo Docker found - Building container...
echo.
docker-compose build
echo.
echo Setup complete!
echo.
echo Usage: run.bat align your_audio.mp3
goto end

:align
if "%2"=="" (
    echo ERROR: Please specify audio file
    echo Example: run.bat align audio.mp3
    exit /b 1
)
if not exist "%2" (
    echo ERROR: File not found: %2
    exit /b 1
)
echo Running alignment on %2...
docker-compose run --rm audio_align python app.py align "%2"
echo.
echo Alignment complete!
for %%F in ("%2") do set filename=%%~nF
echo Output saved to: outputs\%filename%.json
goto end

:clean
echo Cleaning up everything...
echo Removing generated files...
if exist outputs\*.json del /q outputs\*.json
if exist __pycache__ rmdir /s /q __pycache__
if exist utils\__pycache__ rmdir /s /q utils\__pycache__
echo Removing Docker containers and images...
docker-compose down --rmi all --volumes
docker system prune -f
echo Cleanup complete!
goto end

:end
