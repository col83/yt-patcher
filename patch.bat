
@echo off
cd /d "%~dp0"
cls

set "PATCHER=morphe-desktop-2.3.0-dev.3-all.jar"
if not exist "%PATCHER%" (
    echo.
    echo ERROR: Patcher %PATCHER% not exist.
    echo.
    pause
    exit /b 2
)

set "PATCHES_FILE=patches-2.4.0-dev.6.mpp"
if not exist "%PATCHES_FILE%" (
    echo.
    echo ERROR: Patches file %PATCHES_FILE% not exist.
    echo.
    pause
    exit /b 2
)

set "JDK_PATH=jdk-21.0.12.1+1"
if not exist "%JDK_PATH%" (
    echo.
    echo ERROR: %JDK_PATH% not exist.
    echo.
    pause
    exit /b 2
)

set "INPUT_FILE_NAME=youtube"
set "INPUT_FILE_VER=20.26.46"
set "INPUT_FILE=%INPUT_FILE_NAME%_%INPUT_FILE_VER%.apk"
if not exist "%INPUT_FILE%" (
    echo.
    echo ERROR: input file %INPUT_FILE% not exist.
    echo.
    pause
    exit /b 2
)


if not exist "morphe-data" mkdir "morphe-data"
if not exist "morphe-data\libs" mkdir "morphe-data\libs"
if exist "libs\*.jar" copy /Y "libs\*.jar" "morphe-data\libs\" >nul
copy /Y "config.json" "morphe-data\" >nul


if not exist "morphe-data\morphe.keystore" (

    echo.
    "%JDK_PATH%\bin\keytool.exe" -genkeypair ^
      -keystore "morphe-data\morphe.keystore" ^
      -alias Morphe ^
      -keyalg RSA ^
      -keysize 2048 ^
      -validity 10000 ^
      -storetype PKCS12 ^
      -storepass dashi2 ^
      -keypass dashi2 ^
      -dname "CN=Morphe, OU=Android, O=Morphe, L=Unknown, ST=Unknown, C=US"

    if errorlevel 1 (
      echo.
      echo ERROR: Keystore generation failed.
      echo.
      pause
      exit /b 1
    )

)


echo.

%JDK_PATH%\bin\java.exe -Xms1024M -Xmx1512M -Xss256k -XX:ReservedCodeCacheSize=512M ^
-jar "%PATCHER%" patch --patches "%PATCHES_FILE%" ^
-e "Add to queue" ^
-e "Bypass link redirects" ^
-e "Change start page" ^
-e "Copy text" ^
-e "Copy video link" ^
-e "Disable continue watching prompt" ^
-e "Disable DRC audio" ^
-e "Disable fullscreen gestures" ^
-e "Disable haptic feedback" ^
-e "Disable player popup panels" ^
-e "Disable QUIC protocol" ^
-e "Disable rolling number animations" ^
-e "Disable Shorts resuming on startup" ^
-e "Disable sign in to TV popup" ^
-e "Disable video codecs" ^
-e "Enable debugging" ^
-e "Force animations" ^
-e "Force original audio" ^
-e "Fullscreen video scale" ^
-e "GmsCore support" ^
-e "Hide ads" ^
-e "Hide autoplay preview" ^
-e "Hide end screen cards" ^
-e "Hide end screen suggested video" ^
-e "Hide info cards" ^
-e "Hide layout components" ^
-e "Hide player flyout menu components" ^
-e "Hide player overlay buttons" ^
-e "Hide video action buttons" ^
-e "Loop video" ^
-e "Miniplayer" ^
-e "Open channel of live avatar" ^
-e "Open system share sheet" ^
-e "Playback buffer" ^
-e "Playlist button" ^
-e "Playlist improvements" ^
-e "Reload video" ^
-e "Remove background playback restrictions" ^
-e "Remove viewer discretion dialog" ^
-e "Restore original titles" ^
-e "Sanitize sharing links" ^
-e "Save to Watch later" ^
-e "Shorts autoplay" ^
-e "Skip live Shorts" ^
-e "SponsorBlock" ^
-e "Spoof device dimensions" ^
-e "Spoof video streams" ^
--exclusive ^
--keystore "morphe-data\morphe.keystore" --keystore-password "dashi2" --keystore-entry-alias "morphe" --keystore-entry-password "dashi2" ^
--striplibs "arm64-v8a" ^
-o "%INPUT_FILE%-patched.apk" --force ^
"%INPUT_FILE%"

echo.
pause

:: Testing

:: set "JDK_PATH=jdk-21.0.12.1+1"
:: set "PATCHER=morphe-desktop-2.3.0-dev.3-all.jar"

:: rd /s /q "morphe-data"
:: mkdir "morphe-data"

:: copy "config.json" "morphe-data\" >nul

:: mkdir "morphe-data\libs\"
:: copy "libs\" "morphe-data\libs\" >nul

:: mkdir "morphe-data\patches\MorpheApp-morphe-patches\"
:: copy "patches-2.4.0-dev.6.mpp" "morphe-data\patches\MorpheApp-morphe-patches\" >nul

:: "%JDK_PATH%\bin\java.exe" -Xmx2G -XX:+UseLargePagesIndividualAllocation -XX:ReservedCodeCacheSize=512M -jar "%PATCHER%"
