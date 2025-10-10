"""
Whisper Transcription Utility

This module handles audio transcription using OpenAI's Whisper model.
"""

import whisper
from pathlib import Path
import typer


def transcribe_audio(audio_path: Path, model_size: str = "base") -> dict:
    """
    Transcribe an audio file using OpenAI Whisper.

    Args:
        audio_path: Path to the audio file (MP3, WAV, etc.)
        model_size: Whisper model size ("tiny", "base", "small", "medium", "large")

    Returns:
        Dictionary containing:
            - text: Full transcript as plain text
            - segments: List of segment dictionaries with timing info
            - language: Detected language

    Raises:
        Exception: If transcription fails
    """
    try:
        # Load Whisper model
        typer.echo(f"  Loading Whisper '{model_size}' model...")
        model = whisper.load_model(model_size)

        # Transcribe with progress indication
        typer.echo(f"  Transcribing {audio_path.name}...")

        # Whisper transcribe function with word-level timestamps
        result = model.transcribe(
            str(audio_path),
            verbose=False,
            fp16=False,  # Use FP32 for better CPU compatibility
            word_timestamps=True,  # Enable word-level timing
        )

        # Extract relevant information
        transcript_data = {
            "text": result["text"].strip(),
            "segments": result["segments"],
            "language": result.get("language", "en"),
        }

        return transcript_data

    except FileNotFoundError:
        raise Exception(f"Audio file not found: {audio_path}")
    except Exception as e:
        raise Exception(f"Whisper transcription failed: {str(e)}")


def save_transcript(transcript_data: dict, output_path: Path) -> None:
    """
    Save transcript text to a file.

    Args:
        transcript_data: Dictionary containing transcript information
        output_path: Path where to save the transcript text file

    Raises:
        Exception: If file writing fails
    """
    try:
        output_path.write_text(transcript_data["text"], encoding="utf-8")
    except Exception as e:
        raise Exception(f"Failed to save transcript: {str(e)}")
