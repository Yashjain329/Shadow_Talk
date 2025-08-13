#!/bin/bash
set -e
chmod +x build.sh
echo "Starting build process..."

# Check if Flutter SDK exists, update or clone
if [ -d "flutter" ]; then
  echo "Flutter SDK exists, updating..."
  cd flutter
  git pull || { echo "Failed to update Flutter SDK"; exit 1; }
  cd ..
else
  echo "Cloning Flutter SDK..."
  git clone --depth 1 -b 3.32.8 https://github.com/flutter/flutter.git || { echo "Failed to clone Flutter SDK"; exit 1; }
fi

# Ensure correct Flutter version
cd flutter
git checkout 3.32.8 || { echo "Failed to checkout Flutter version"; exit 1; }
cd ..

# Set Flutter PATH
export PATH="$PWD/flutter/bin:$PATH"
echo "Flutter path set to: $PATH"

# Verify Flutter installation
flutter --version || { echo "Flutter command failed"; exit 1; }

# Enable web support
flutter config --enable-web || { echo "Failed to enable Flutter web"; exit 1; }

# Run pub get to resolve dependencies
echo "Running flutter pub get..."
flutter pub get || { echo "Failed to resolve dependencies"; exit 1; }

# Build Flutter web
echo "Building Flutter web..."
flutter build web --release || { echo "Flutter build web failed"; exit 1; }

# Verify build output
if [ -d "build/web" ]; then
  echo "Build successful, build/web directory created"
else
  echo "Error: build/web directory not found"
  exit 1
fi

echo "Build complete"
