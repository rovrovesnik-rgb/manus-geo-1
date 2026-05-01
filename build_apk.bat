@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo   GEO DASH - Automated Build for Windows
echo ==========================================

:: 1. Check for Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java (JDK) not found. Please install JDK 11 or 17.
    pause
    exit /b 1
)

:: 2. Setup Gradle Wrapper if missing
if not exist "gradlew.bat" (
    echo [INFO] Setting up Gradle wrapper...
    :: Note: In a real Windows environment, users would have these files from the project ZIP.
    :: This script assumes it's running inside the project folder.
)

:: 3. Detect Android SDK
if "%ANDROID_HOME%"=="" (
    set "SDK_PATH=%LOCALAPPDATA%\Android\Sdk"
    if exist "!SDK_PATH!" (
        set "ANDROID_HOME=!SDK_PATH!"
    ) else (
        echo [ERROR] ANDROID_HOME environment variable is not set.
        echo Please set it to your Android SDK location.
        echo Example: set ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk
        pause
        exit /b 1
    )
)

echo [INFO] Using Android SDK at: %ANDROID_HOME%

:: 4. Create local.properties
echo sdk.dir=%ANDROID_HOME:\=\\% > local.properties

:: 5. Build APK
echo [INFO] Building Debug APK...
call gradlew.bat assembleDebug --no-daemon

:: 6. Locate Result
set "APK_PATH=app\build\outputs\apk\debug\app-debug.apk"
if exist "%APK_PATH%" (
    echo ==========================================
    echo   SUCCESS: Build Finished!
    echo   APK Location: %APK_PATH%
    echo ==========================================
) else (
    echo [ERROR] Build failed. Check the logs above.
)

pause
