#!/bin/bash
echo "[1/4] Syncing repository..."
git fetch origin
git reset --hard origin/master

echo "[2/4] Cleaning dependencies..."
rm -f pubspec.lock
flutter pub get

echo "[3/4] Analyzing code..."
flutter analyze

echo "[4/4] Building release APK..."
flutter build apk --release --split-per-abi
echo "Build process completed!"
