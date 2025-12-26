# Makefile for Flutter Web + Vercel Deploy

# Variables
SCRIPT_DIR = scripts
# Get current date/time dynamically for the commit message
NOW := $(shell date '+%Y-%m-%d %H:%M:%S')

.PHONY: icons build vercel deploy-firebase save ship

# 1. Generate icons (System check)
icons:
	@sh $(SCRIPT_DIR)/icons.sh

# 2. Build the web release with your specific flags
build: icons
	flutter build web --release --no-tree-shake-icons
	
# 3. Deploy to Vercel (Production)
# We cd into build/web because that is where the static files live
vercel:
	cd build/web && vercel --prod

# Optional: Keep Firebase deploy just in case you go back
deploy-firebase:
	firebase deploy

run: build vercel
	@echo "Build and deploy complete!"

# 4. Git Save (Add & Commit with Timestamp)
save:
	git add .
	git commit -m "Updates on $(NOW) from Harare" || echo "Nothing to commit"

# --- THE MASTER COMMAND ---
# Runs: Build -> Vercel Deploy -> Git Save -> Git Push
ship: build vercel save
	git push origin main
	@echo "🚀 Shipped to Vercel and GitHub successfully!"