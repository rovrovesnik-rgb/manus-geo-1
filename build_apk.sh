#!/bin/bash

# GEO DASH - Automated APK Build Script
# This script sets up the environment and builds the debug APK.

set -e

echo "🚀 Starting GEO DASH Build Process..."

# 1. Check for Java
if ! command -v java &> /dev/null; then
    echo "❌ Java not found. Please install JDK 11 or 17."
    exit 1
fi

# 2. Setup Gradle Wrapper if missing
if [ ! -f gradlew ]; then
    echo "📦 Setting up Gradle wrapper..."
    curl -L https://raw.githubusercontent.com/gradle/gradle/master/gradlew -o gradlew
    chmod +x gradlew
    mkdir -p gradle/wrapper
    curl -L https://raw.githubusercontent.com/gradle/gradle/master/gradle/wrapper/gradle-wrapper.jar -o gradle/wrapper/gradle-wrapper.jar
    echo "distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-bin.zip
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists" > gradle/wrapper/gradle-wrapper.properties
fi

# 3. Detect Android SDK
if [ -z "$ANDROID_HOME" ]; then
    # Common locations
    LOCATIONS=("$HOME/Android/Sdk" "$HOME/Library/Android/sdk" "/usr/lib/android-sdk" "/opt/android-sdk")
    for loc in "${LOCATIONS[@]}"; do
        if [ -d "$loc" ]; then
            export ANDROID_HOME="$loc"
            break
        fi
    done
fi

if [ -z "$ANDROID_HOME" ]; then
    echo "❌ ANDROID_HOME not found."
    echo "Please set ANDROID_HOME to your Android SDK path."
    echo "Example: export ANDROID_HOME=/path/to/sdk"
    exit 1
fi

echo "✅ Using Android SDK at: $ANDROID_HOME"

# 4. Create local.properties
echo "sdk.dir=$ANDROID_HOME" > local.properties

# 5. Build APK
echo "🏗️ Building Debug APK..."
./gradlew assembleDebug --no-daemon

# 6. Locate Result
APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
if [ -f "$APK_PATH" ]; then
    SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo "--------------------------------------"
    echo "✅ BUILD SUCCESSFUL!"
    echo "📦 APK Location: $APK_PATH"
    echo "📊 File Size: $SIZE"
    echo "📱 You can now install this on your Android device."
    echo "--------------------------------------"
else
    echo "❌ Build failed. Check the logs above."
    exit 1
fi
