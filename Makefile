.PHONY: help install align clean

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help:
	@printf "$(BLUE)╔════════════════════════════════════════════════════════╗$(NC)\n"
	@printf "$(BLUE)║        Audio-to-JSON Alignment Tool                    ║$(NC)\n"
	@printf "$(BLUE)║        Word-level timing using Whisper                 ║$(NC)\n"
	@printf "$(BLUE)╚════════════════════════════════════════════════════════╝$(NC)\n"
	@printf "\n"
	@printf "$(GREEN)🚀 Quick Start:$(NC)\n"
	@printf "  $(BLUE)make install$(NC)              - One-click setup (first time only)\n"
	@printf "  $(BLUE)make align audio.mp3$(NC)      - Process audio file\n"
	@printf "\n"
	@printf "$(GREEN)Main Commands:$(NC)\n"
	@printf "  make install              - Setup Docker and build container\n"
	@printf "  make align <file>         - Align audio file and export JSON\n"
	@printf "  make clean                - Remove everything (Docker, files, cache)\n"
	@printf "  make help                 - Show this help message\n"
	@printf "\n"
	@printf "$(GREEN)Examples:$(NC)\n"
	@printf "  $(BLUE)make align podcast.mp3$(NC)\n"
	@printf "  $(BLUE)make align inputs/interview.wav$(NC)\n"
	@printf "\n"
	@printf "$(YELLOW)Output:$(NC) Files saved to outputs/<filename>.json\n"
	@printf "\n"
	@printf "$(GREEN)Requirements:$(NC) Docker\n"

install:
	@printf "$(BLUE)╔════════════════════════════════════════════════════════╗$(NC)\n"
	@printf "$(BLUE)║  ONE-CLICK INSTALLER                                   ║$(NC)\n"
	@printf "$(BLUE)╚════════════════════════════════════════════════════════╝$(NC)\n"
	@printf "\n"
	@printf "$(YELLOW)Checking for Docker...$(NC)\n"
	@if command -v docker > /dev/null 2>&1; then \
		printf "$(GREEN)✓ Docker found - Building container...$(NC)\n\n"; \
		docker-compose build; \
		printf "\n$(GREEN)✓ Setup complete!$(NC)\n"; \
		printf "\n$(YELLOW)Usage:$(NC) make align your_audio.mp3\n"; \
	else \
		printf "$(RED)❌ Docker not found. Please install Docker first.$(NC)\n"; \
		printf "Visit: https://docs.docker.com/get-docker/\n"; \
		exit 1; \
	fi

align:
	@if [ -z "$(word 2,$(MAKECMDGOALS))" ]; then \
		printf "$(RED)❌ Please specify audio file$(NC)\n"; \
		printf "Example: make align audio.mp3\n"; \
		exit 1; \
	fi
	@if [ ! -f "$(word 2,$(MAKECMDGOALS))" ]; then \
		printf "$(RED)❌ File not found: $(word 2,$(MAKECMDGOALS))$(NC)\n"; \
		exit 1; \
	fi
	@printf "$(BLUE)Running alignment on $(word 2,$(MAKECMDGOALS))...$(NC)\n"
	@docker-compose run --rm audio_align python app.py align "$(word 2,$(MAKECMDGOALS))"
	@printf "\n"
	@printf "$(GREEN)✓ Alignment complete!$(NC)\n"
	@printf "$(BLUE)Output saved to: outputs/$(shell basename $(word 2,$(MAKECMDGOALS)) | sed 's/\.[^.]*$$/.json/')$(NC)\n"

# This prevents make from trying to interpret the filename as a target
%:
	@:

clean:
	@printf "$(BLUE)Cleaning up everything...$(NC)\n"
	@printf "$(YELLOW)Removing generated files...$(NC)\n"
	@rm -rf outputs/*.json 2>/dev/null || true
	@rm -rf __pycache__ utils/__pycache__ 2>/dev/null || true
	@printf "$(YELLOW)Removing Docker containers and images...$(NC)\n"
	@docker-compose down --rmi all --volumes 2>/dev/null || true
	@docker system prune -f 2>/dev/null || true
	@printf "$(GREEN)✓ Full cleanup complete!$(NC)\n"
