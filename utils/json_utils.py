"""
JSON Export Utility

This module handles exporting alignment data to structured JSON format.
"""

import json
from pathlib import Path


def validate_alignment_data(alignment_data: dict) -> bool:
    """
    Validate that alignment data contains required fields.

    Args:
        alignment_data: Dictionary containing alignment information

    Returns:
        True if valid, False otherwise
    """

    if "words" not in alignment_data:
        return False

    if not isinstance(alignment_data["words"], list):
        return False

    # Validate word structure
    for word in alignment_data["words"]:
        if not all(key in word for key in ["text", "start", "end"]):
            return False
        if not isinstance(word["start"], (int, float)):
            return False
        if not isinstance(word["end"], (int, float)):
            return False

    # Validate phoneme structure if present (optional)
    if "phonemes" in alignment_data and isinstance(alignment_data["phonemes"], list):
        for phoneme in alignment_data["phonemes"]:
            if not all(key in phoneme for key in ["symbol", "start", "end"]):
                return False
            if not isinstance(phoneme["start"], (int, float)):
                return False
            if not isinstance(phoneme["end"], (int, float)):
                return False

    return True


def export_to_json(alignment_data: dict, output_path: Path) -> None:
    """
    Export alignment data to a JSON file.

    The JSON structure follows this format:
    {
        "words": [
            {"text": "hello", "start": 0.13, "end": 0.41},
            ...
        ],
        "phonemes": [
            {"symbol": "h", "start": 0.13, "end": 0.17},
            ...
        ]
    }

    Args:
        alignment_data: Dictionary containing words and phonemes alignment
        output_path: Path where to save the JSON file

    Raises:
        Exception: If validation fails or file writing fails
    """
    try:
        # Validate alignment data
        if not validate_alignment_data(alignment_data):
            raise ValueError("Invalid alignment data structure")

        # Prepare output data
        output_data = {"words": alignment_data["words"]}

        # Include phonemes if available
        if "phonemes" in alignment_data:
            output_data["phonemes"] = alignment_data["phonemes"]

        # Include transcript if available
        if "transcript" in alignment_data:
            output_data["transcript"] = alignment_data["transcript"]

        # Include whisper segments if available (useful for debugging)
        if "whisper_segments" in alignment_data:
            output_data["whisper_segments"] = alignment_data["whisper_segments"]

        # Write JSON file with pretty formatting
        with output_path.open("w", encoding="utf-8") as f:
            json.dump(output_data, f, indent=2, ensure_ascii=False)

    except Exception as e:
        raise Exception(f"Failed to export JSON: {str(e)}")


def load_alignment_json(json_path: Path) -> dict:
    """
    Load alignment data from a JSON file.

    Args:
        json_path: Path to the JSON file

    Returns:
        Dictionary containing alignment data

    Raises:
        Exception: If file reading or parsing fails
    """
    try:
        with json_path.open("r", encoding="utf-8") as f:
            data = json.load(f)

        if not validate_alignment_data(data):
            raise ValueError("Invalid JSON structure")

        return data

    except Exception as e:
        raise Exception(f"Failed to load JSON: {str(e)}")


def verify_timing_accuracy(
    alignment_data: dict,
) -> bool:
    """
    Verify that alignment timing is internally consistent.

    Args:
        alignment_data: Dictionary containing alignment information
        tolerance_ms: Acceptable timing gap in milliseconds (default: 20ms)

    Returns:
        True if timing is consistent within tolerance

    Raises:
        Exception: If timing validation fails
    """

    # Check words timing
    for i, word in enumerate(alignment_data["words"]):
        if word["start"] >= word["end"]:
            raise Exception(f"Word {i} has invalid timing: start >= end")

        if i > 0:
            prev_word = alignment_data["words"][i - 1]
            gap = word["start"] - prev_word["end"]
            # Allow small gaps or overlaps within tolerance
            if abs(gap) > 1.0:  # More than 1 second gap is suspicious
                raise Exception(
                    f"Large gap detected between words {i - 1} and {i}: {gap:.3f}s"
                )

    # Check phonemes timing
    for i, phoneme in enumerate(alignment_data["phonemes"]):
        if phoneme["start"] >= phoneme["end"]:
            raise Exception(f"Phoneme {i} has invalid timing: start >= end")

    return True
