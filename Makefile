# Makefile for SteerWise (Flutter App)

# This Makefile is a simple development toolkit for the SteerWise Flutter app.
# To use it: run make run, make build-apk, etc. from the terminal in your project root.

APP_NAME=SteerWise
FLUTTER=flutter

.PHONY: help
help:
	@echo "$(APP_NAME) Dev Toolkit"
	@echo "Available targets:"
	@echo "  make run            - Run the app"
	@echo "  make build-apk      - Build Android APK"
	@echo "  make build-apk-split - Build smaller per-ABI release APKs"
	@echo "  make build-ios      - Build iOS app"
	@echo "  make build-web      - Build for web"
	@echo "  make build-windows  - Build for Windows"
	@echo "  make build-linux    - Build for Linux"
	@echo "  make build-macos    - Build for macOS"
	@echo "  make analyse        - Run the Flutter analyser"
	@echo "  make format         - Format Dart code"
	@echo "  make test           - Run tests"
	@echo "  make icons          - Generate launcher icons"
	@echo "  make docs           - Convert docs/md to docs/html"
	@echo "  make foss-audit     - Check for non-free dependencies"
	@echo "  make reuse-lint     - Check licensing (REUSE)"
	@echo "  make clean          - Clean project"
	@echo "  make pub-get        - Get dependencies"
	@echo "  make ios-open       - Open iOS module in Xcode"
	@echo "  make android-open   - Open Android module in Android Studio"

.PHONY: run
run:
	@echo "Running $(APP_NAME)..."
	@$(FLUTTER) run

.PHONY: build-apk
build-apk:
	@echo "Building APK..."
	@$(FLUTTER) build apk

.PHONY: build-apk-split
build-apk-split:
	@echo "Building per-ABI release APKs..."
	@$(FLUTTER) build apk --release --split-per-abi

.PHONY: build-ios
build-ios:
	@echo "Building for iOS..."
	@$(FLUTTER) build ios

.PHONY: build-web
build-web:
	@echo "Building for web..."
	@$(FLUTTER) build web

.PHONY: build-windows
build-windows:
	@echo "Building for Windows..."
	@$(FLUTTER) build windows

.PHONY: build-linux
build-linux:
	@echo "Building for Linux..."
	@$(FLUTTER) build linux

.PHONY: build-macos
build-macos:
	@echo "Building for macOS..."
	@$(FLUTTER) build macos

.PHONY: analyse
analyse:
	@echo "Running static analyser..."
	@$(FLUTTER) analyze

.PHONY: format
format:
	@echo "Formatting Dart code..."
	@dart format lib/ test/

.PHONY: test
test:
	@echo "Running tests..."
	@$(FLUTTER) test

.PHONY: icons
icons:
	@echo "Generating launcher icons..."
	@dart run flutter_launcher_icons

.PHONY: foss-audit
foss-audit:
	@./scripts/foss_audit.sh

.PHONY: reuse-lint
reuse-lint:
	@pipx run reuse lint

.PHONY: docs
docs:
	@./scripts/md-to-html.sh docs/md docs/html

.PHONY: clean
clean:
	@echo "Cleaning project..."
	@$(FLUTTER) clean

.PHONY: pub-get
pub-get:
	@echo "Fetching packages..."
	@$(FLUTTER) pub get

.PHONY: ios-open
ios-open:
	@open ios/Runner.xcworkspace

.PHONY: android-open
android-open:
	@studio android/