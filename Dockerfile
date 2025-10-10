# Audio-to-JSON Alignment CLI - Docker Image
FROM continuumio/miniconda3:latest

# Set working directory
WORKDIR /app

# Install system dependencies (ffmpeg for audio processing)
RUN apt-get update && apt-get install -y \
  ffmpeg \
  && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Create conda environment
RUN conda create -n audio_align python=3.10 -y && \
  echo "source activate audio_align" > ~/.bashrc

# Install Python packages (Whisper, PyTorch, etc.)
RUN /opt/conda/envs/audio_align/bin/pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Set PATH to use conda environment
ENV PATH=/opt/conda/envs/audio_align/bin:$PATH

# Default command
CMD ["/bin/bash"]
