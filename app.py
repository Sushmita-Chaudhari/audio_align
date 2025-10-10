"""
Audio-to-JSON Alignment CLI Tool

This CLI tool uses OpenAI Whisper for transcription with word-level timing,
outputting structured JSON with millisecond precision.
"""

import typer
from pathlib import Path
from typing import Optional
from utils.whisper_utils import transcribe_audio
from utils.json_utils import export_to_json

app = typer.Typer(help="Audio-to-JSON Alignment CLI Tool")


@app.command()
def align(
    audio_file: Path = typer.Argument(
        ..., exists=True, help="Path to the MP3 audio file to align"
    ),
    output: Optional[Path] = typer.Option(
        None,
        "--output",
        "-o",
        help="Output JSON file path (default: outputs/<audio_filename>.json)",
    ),
    whisper_model: str = typer.Option(
        "base",
        "--whisper-model",
        "-w",
        help="Whisper model size (tiny, base, small, medium, large)",
    ),
):
    """
    Align an audio file and export word/phoneme timing to JSON.

    This command performs three steps:
    1. Transcribes audio using OpenAI Whisper
    2. Aligns transcript with audio using Montreal Forced Aligner
    3. Exports alignment data as structured JSON
    """
    try:
        # Validate input file
        if not audio_file.exists():
            typer.echo(f"❌ Error: Audio file '{audio_file}' not found.", err=True)
            raise typer.Exit(1)

        # Create outputs folder if it doesn't exist
        outputs_dir = Path("outputs")
        outputs_dir.mkdir(exist_ok=True)

        # Auto-generate output filename if not specified
        if output is None:
            output_filename = audio_file.stem + ".json"
            output = outputs_dir / output_filename

        typer.echo(f"🎵 Processing audio file: {audio_file}")
        typer.echo("")

        # Step 1: Transcribe with Whisper
        typer.echo("📝 Step 1/3: Transcribing audio with Whisper...")
        transcript_data = transcribe_audio(audio_file, model_size=whisper_model)
        typer.echo(
            f"✓ Transcription complete: {len(transcript_data['text'].split())} words detected"
        )
        typer.echo("")

        # Step 2: Extract word-level timing from Whisper
        typer.echo("🔍 Step 2/3: Extracting word-level timing...")

        # Whisper already provides word-level timing
        words = []
        for segment in transcript_data["segments"]:
            if "words" in segment and segment["words"]:
                for word_data in segment["words"]:
                    word_text = word_data.get("word", "").strip()
                    # Remove punctuation
                    import re

                    word_text = re.sub(r"[^\w\s\'-]", "", word_text)
                    if word_text:
                        words.append(
                            {
                                "text": word_text,
                                "start": round(word_data.get("start", 0), 3),
                                "end": round(word_data.get("end", 0), 3),
                            }
                        )

        alignment_data = {
            "transcript": transcript_data["text"],
            "words": words,
            "whisper_segments": transcript_data["segments"],
        }

        typer.echo(f"✓ Word timing extracted: {len(words)} words")
        typer.echo("")

        # Step 3: Export to JSON
        typer.echo("💾 Step 3/3: Exporting to JSON...")
        export_to_json(alignment_data, output)
        typer.echo(f"✓ JSON exported to: {output}")
        typer.echo("")

        typer.echo("✅ Pipeline complete! Alignment data saved successfully.")

    except Exception as e:
        typer.echo(f"❌ Error: {str(e)}", err=True)
        raise typer.Exit(1)


@app.command()
def version():
    """Show the version of the audio_align tool."""
    typer.echo("audio_align v1.0.0")


if __name__ == "__main__":
    app()
