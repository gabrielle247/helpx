# Makefile for Flutter Web + Firebase Deploy

# Variables
SCRIPT_DIR = scripts
# Get current date/time dynamically
NOW := $(shell date '+%Y-%m-%d %H:%M:%S')

.PHONY: icons build deploy run save

# Generate icons from favicon.svg before building
icons:
	@sh $(SCRIPT_DIR)/icons.sh

# Build the web release (depends on icons)
build: icons
	flutter build web --release

# Deploy to Firebase
deploy:
	firebase deploy

# Full sequence: Icons -> Build -> Deploy
run: build deploy
	@echo "Build and deploy complete!"

# NEW: Git Save Command
save:
	git add .
	git commit -m "Added changes on $(NOW) from Harare, Zimbabwe"
	@echo "✅ Saved with timestamp: $(NOW)"
	https://github.com/gabrielle247/helpx