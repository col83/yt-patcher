
@echo off
cd /d "%~dp0"
cls

set "PATCHER=morphe-desktop-2.2.0-dev.12-all.jar"
if not exist "%PATCHER%" (
    echo.
    echo ERROR: Patcher %PATCHER% not exist.
    echo.
    pause
    exit /b 2
)

set "PATCHES_FILE=patches-2.2.0.mpp"
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
set "INPUT_FILE_VER=21.30.216"
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
--keystore "morphe-data\morphe.keystore" ^
--keystore-password "dashi2" ^
--keystore-entry-alias "morphe" ^
--keystore-entry-password "dashi2" ^
-o "%INPUT_FILE%-patched.apk" --force ^
-d "Alternative thumbnails" ^
-d "Ambient mode" ^
-d "Captions" ^
-d "Change header" ^
-d "Change installer source" ^
-d "Change picture-in-picture actions" ^
-d "Channel whitelist" ^
-d "Clone app" ^
-d "Custom branding" ^
-d "Custom font" ^
-d "Custom player overlay opacity" ^
-d "DeArrow" ^
-d "Downloads" ^
-d "Enable debugging" ^
-d "Mute button" ^
-d "Network proxy" ^
-d "Niconico comments" ^
-d "On-the-go player" ^
-d "Open Shorts in regular player" ^
-d "Playback speed" ^
-d "PoToken provider" ^
-d "Return YouTube Dislike" ^
-d "Spoof video streams" ^
-d "Spoof signature" ^
-d "Theme" ^
-d "Voice over translation" ^
-d "Wide search bar" ^
"%INPUT_FILE%"

echo.
pause

:: Testing

:: set "JDK_PATH=jdk-21.0.12.1+1"
:: set "PATCHER=morphe-desktop-2.2.0-dev.12-all.jar"

:: rd /s /q "morphe-data"
:: mkdir "morphe-data"
:: copy "config.json" "morphe-data\" >nul
:: mkdir "morphe-data\libs\"
:: copy "libs\" "morphe-data\libs\" >nul
:: mkdir "morphe-data\patches\MorpheApp-morphe-patches\"
:: copy "patches-2.2.0.mpp" "morphe-data\patches\MorpheApp-morphe-patches\" >nul

:: "%JDK_PATH%\bin\java.exe" -Xms1024M -Xmx1512M -XX:+UseZGC -Xss256k -XX:ReservedCodeCacheSize=512M -jar "%PATCHER%"
