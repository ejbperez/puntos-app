#!/usr/bin/env bash

set -euo pipefail

# Vercel builds run on Linux. Install Flutter outside the repository so the
# SDK is not included in the deployment output or committed to Git.
FLUTTER_DIR="${VERCEL_FLUTTER_DIR:-/tmp/flutter}"
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  rm -rf "$FLUTTER_DIR"
  git clone --depth 1 --branch "$FLUTTER_CHANNEL" \
    https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --no-analytics
flutter precache --web
flutter pub get
flutter build web --release
