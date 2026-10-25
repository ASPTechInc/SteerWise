#!/bin/bash

# Purpose:
# Checks that SteerWise has no non-free dependencies that would stop it
# being published on F-Droid (Google Play services, Firebase, Google Maps,
# ads or other proprietary SDKs).
#
# It checks the resolved Dart packages in pubspec.lock and the Android
# release runtime classpath reported by Gradle.

# Usage:
# chmod +x ./scripts/foss_audit.sh
# ./scripts/foss_audit.sh
#
# Run `flutter pub get` and `flutter build apk --config-only` first so that
# pubspec.lock and the Gradle wrapper exist.

set -euo pipefail

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
cd "$ROOT_DIR"

# Dart packages that wrap proprietary SDKs
NON_FREE_PUB='^  (google_maps_flutter[a-z_]*|firebase_[a-z_]+|cloud_firestore|google_mobile_ads|google_sign_in[a-z_]*|in_app_review|in_app_update|play_install_referrer|sentry_flutter|onesignal_flutter):'

# Maven groups for proprietary Android libraries
NON_FREE_MAVEN='com\.google\.android\.gms|com\.google\.firebase|com\.google\.android\.play|com\.google\.android\.libraries\.places|com\.google\.mlkit|com\.android\.billingclient|com\.crashlytics|io\.sentry'

status=0

echo "Checking pubspec.lock for non-free packages..."
if [[ ! -f pubspec.lock ]]; then
  echo "Error: pubspec.lock not found. Run 'flutter pub get' first."
  exit 1
fi
if grep -E "$NON_FREE_PUB" pubspec.lock; then
  echo "Error: non-free Dart packages found (listed above)."
  status=1
else
  echo "No non-free Dart packages found."
fi

echo "Checking the Android release runtime classpath..."
if [[ ! -x android/gradlew ]]; then
  echo "Error: android/gradlew not found. Run 'flutter build apk --config-only' first."
  exit 1
fi
deps=$(cd android && ./gradlew -q :app:dependencies --configuration releaseRuntimeClasspath)
if grep -E "$NON_FREE_MAVEN" <<< "$deps" | sort -u; then
  echo "Error: non-free Android libraries found (listed above)."
  status=1
else
  echo "No non-free Android libraries found."
fi

exit $status
