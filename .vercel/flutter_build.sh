#!/bin/bash

# Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Verify Flutter works
flutter --version

# Enable web
flutter config --enable-web

# Get packages
flutter pub get

# Build web
flutter build web --release
