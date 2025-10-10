# Windows Quick Start Guide

## Prerequisites

1. Install Docker Desktop: https://docs.docker.com/desktop/install/windows-install/
2. Make sure Docker Desktop is running (check system tray icon)

## Installation

Open Command Prompt or PowerShell in this folder and run:

**Command Prompt:**
```cmd
run.bat install
```

**PowerShell:**
```powershell
.\run.ps1 install
```

Wait 2-3 minutes for Docker to build the container.

## Usage

### Process an Audio File

**Command Prompt:**
```cmd
run.bat align your_audio.mp3
```

**PowerShell:**
```powershell
.\run.ps1 align your_audio.mp3
```

### Examples

```cmd
REM Process a file in the current directory
run.bat align podcast.mp3

REM Process a file in inputs folder
run.bat align inputs\interview.mp3

REM Process a file with full path
run.bat align "C:\Users\YourName\Music\audio.mp3"
```

### Output Location

All JSON files are saved to the `outputs\` folder with the same name as your audio file:

```
Input:  podcast.mp3
Output: outputs\podcast.json
```

## All Commands

```cmd
run.bat help       - Show help message
run.bat install    - Setup Docker container (first time only)
run.bat align FILE - Process audio file
run.bat clean      - Remove all generated files and Docker images
```

## Troubleshooting

### "Docker not found"
- Make sure Docker Desktop is installed and running
- Check the system tray for Docker icon
- Restart Command Prompt/PowerShell after installing Docker

### "File not found"
- Make sure the audio file path is correct
- Use quotes for paths with spaces: `run.bat align "my file.mp3"`
- Use backslashes `\` for Windows paths, not forward slashes `/`

### "Permission denied"
- Run as Administrator (right-click → Run as administrator)
- Make sure Docker Desktop has permission to access your files

## Alternative: Direct Docker Commands

If the scripts don't work, use Docker directly:

```cmd
REM Install
docker-compose build

REM Run alignment
docker-compose run --rm audio_align python app.py align your_audio.mp3

REM Clean up
docker-compose down --rmi all --volumes
```

## Need Help?

Check the main README.md for detailed documentation.
