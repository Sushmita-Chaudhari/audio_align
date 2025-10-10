# Audio-to-JSON Alignment Tool

A cross-platform command-line tool that performs precise **word-level audio alignment** using OpenAI Whisper, outputting clean structured JSON with millisecond-precision timing.

## Features

- ✅ Automatic transcription using OpenAI Whisper
- ✅ Word-level timing with millisecond precision
- ✅ Clean JSON output format
- ✅ Cross-platform support (Windows, macOS, Linux)
- ✅ One-command installation via Docker
- ✅ Simple usage - just one command!
- ✅ Automatic output organization

---

## Quick Start

### 1. Install (One Command)

**Linux/macOS:**
```bash
make install
```

**Windows (Batch):**
```cmd
run.bat install
```

**Windows (PowerShell):**
```powershell
.\run.ps1 install
```

**Wait 2-3 minutes.** This automatically sets up Docker and builds the container with all dependencies.

---

### 2. Run Alignment

**Linux/macOS:**
```bash
make align your_audio.mp3
```

**Windows (Batch):**
```cmd
run.bat align your_audio.mp3
```

**Windows (PowerShell):**
```powershell
.\run.ps1 align your_audio.mp3
```

That's it! Output will be saved to `outputs/your_audio.json`

---

## Installation

### One-Click Install (Recommended)

**Linux/macOS:**
```bash
make install
```

**Windows:**
```cmd
run.bat install
```

Or with PowerShell:
```powershell
.\run.ps1 install
```

This will:
- ✓ Check if Docker is installed
- ✓ Build Docker container with Whisper
- ✓ Install all dependencies automatically

### Requirements

- **Docker Desktop** (required for all platforms)
  - Windows: https://docs.docker.com/desktop/install/windows-install/
  - macOS: https://docs.docker.com/desktop/install/mac-install/
  - Linux: https://docs.docker.com/desktop/install/linux/
- 2-4 GB RAM
- Internet connection (first run only, for downloading Whisper models)

---

## Usage

### Linux/macOS

```bash
make align audio_file.mp3
```

### Windows

**Option 1: Batch Script**
```cmd
run.bat align audio_file.mp3
```

**Option 2: PowerShell**
```powershell
.\run.ps1 align audio_file.mp3
```

**Option 3: Direct Docker**
```cmd
docker-compose run --rm audio_align python app.py align audio_file.mp3
```

### Custom Output Location

```bash
make align audio.mp3 -o custom_output.json
```

### Using Different Whisper Models

Edit `app.py` to change the model size:

- `tiny` - Fastest, least accurate
- `base` - **Default** - Good balance
- `small` - Better accuracy
- `medium` - High accuracy
- `large` - Best accuracy, slowest

---

## Output Format

The tool generates a JSON file with the following structure:

```json
{
  "words": [
    {
      "text": "hello",
      "start": 0.0,
      "end": 0.42
    },
    {
      "text": "world",
      "start": 0.42,
      "end": 0.88
    }
  ],
  "transcript": "hello world",
  "whisper_segments": [...]
}
```

### Fields:

- **`words`**: Array of word objects with timing
  - `text`: The word (punctuation removed)
  - `start`: Start time in seconds (3 decimal places)
  - `end`: End time in seconds (3 decimal places)

- **`transcript`**: Full transcript as plain text

- **`whisper_segments`**: Detailed Whisper output (for debugging)

---

## Output Location

All output files are automatically saved to the `outputs/` folder with the same name as the input audio file:

```
Input:  harpercarrollai-20251010-0001.mp3
Output: outputs/harpercarrollai-20251010-0001.json
```

---

## Examples

### Example 1: Basic Usage

```bash
make align podcast.mp3
# Output: outputs/podcast.json
```

### Example 2: Multiple Files

```bash
for file in *.mp3; do
    make align "$file"
done
```

### Example 3: Check Results

```bash
# View first 10 words
jq '.words[0:10]' outputs/podcast.json

# Count total words
jq '.words | length' outputs/podcast.json

# View transcript
jq '.transcript' outputs/podcast.json
```

---

## How It Works

The tool uses a streamlined two-step pipeline:

### Step 1: Transcription (Whisper)

- Loads the Whisper model
- Transcribes audio with **word-level timestamps enabled**
- Extracts precise timing for each word

### Step 2: JSON Export

- Cleans word text (removes punctuation)
- Validates timing consistency
- Exports to structured JSON format

---

## Performance

**Hardware**: Docker container (Whisper base model)

**Processing Time**: ~1-2 minutes for 5-minute audio

Breakdown:

- Whisper transcription: ~1-2 minutes (includes word-level timing)
- JSON export: <1 second

**First Run**: Additional 30 seconds to download Whisper model (cached after)

---

## Project Structure

```
audio_align/
├── app.py                    # Main CLI application
├── utils/
│   ├── whisper_utils.py     # Whisper transcription
│   └── json_utils.py        # JSON export and validation
├── outputs/                  # Generated JSON files
├── Makefile                  # Build and run commands
├── Dockerfile               # Docker container setup
├── docker-compose.yml       # Docker orchestration
├── requirements.txt         # Python dependencies
└── README.md               # This file
```

---

## Makefile Commands

```bash
make install        # One-click setup
make align FILE     # Align audio file
make help          # Show all commands
make clean         # Clean generated files
```

---

## Troubleshooting

### Docker Not Installed?

Install Docker from: https://docs.docker.com/get-docker/

Then run:

```bash
make install
```

### Out of Memory?

The base model uses ~1GB RAM. If you have memory issues, the tool will automatically use CPU mode.

### Audio Format Not Supported?

Whisper supports: MP3, WAV, M4A, FLAC, OGG, and more.

If you have issues, convert to MP3 or WAV first.

---

## Technical Details

- **Transcription**: OpenAI Whisper (PyTorch implementation)
- **Word Timing**: Whisper's native word-level timestamps
- **Precision**: 3 decimal places (millisecond accuracy)
- **Container**: Docker with Miniconda + Python 3.10
- **CLI Framework**: Typer

---

## Requirements File

Key dependencies:

- `openai-whisper>=20231117`
- `torch>=2.0.0`
- `typer[all]==0.9.0`

All dependencies are automatically installed via Docker.

---

## Version

**audio_align v1.0.0**

---

## Support

For issues:

1. Check this troubleshooting section
2. Review Whisper documentation: https://github.com/openai/whisper
3. Ensure Docker is running: `docker --version`

---

## License

This project is provided as-is for educational and research purposes.

## Credits

- **OpenAI Whisper**: https://github.com/openai/whisper
- **Typer**: https://typer.tiangolo.com/
