
Set-Location $PSScriptRoot
Clear-Host

$PATCHER = "morphe-desktop-1.19.0-dev.5-all.jar"
if (-not (Test-Path $PATCHER)) {
    Write-Host ""
    Write-Host "ERROR: Patcher $PATCHER not exist."
    Write-Host ""
    Read-Host "Press Enter to continue"
    exit 2
}

$PATCHES_FILE = "patches-1.48.0-dev.12.mpp"
if (-not (Test-Path $PATCHES_FILE)) {
    Write-Host ""
    Write-Host "ERROR: Patches file $PATCHES_FILE not exist."
    Write-Host ""
    Read-Host "Press Enter to continue"
    exit 2
}

$JDK_PATH = "jdk-21.0.12.1+1"
if (-not (Test-Path $JDK_PATH)) {
    Write-Host ""
    Write-Host "ERROR: $JDK_PATH not exist."
    Write-Host ""
    Read-Host "Press Enter to continue"
    exit 2
}

$INPUT_FILE_NAME = "youtube"
$INPUT_FILE_VER = "21.20.405"
$INPUT_FILE = "${INPUT_FILE_NAME}_${INPUT_FILE_VER}.apk"
if (-not (Test-Path $INPUT_FILE)) {
    Write-Host ""
    Write-Host "ERROR: input file $INPUT_FILE not exist."
    Write-Host ""
    Read-Host "Press Enter to continue"
    exit 2
}


New-Item -Path "morphe-data\libs" -ItemType Directory -Force | Out-Null
if (Test-Path "libs\*.jar") {
    Copy-Item -Path "libs\*.jar" -Destination "morphe-data\libs\" -Force
}
Copy-Item -Path "config.json" -Destination "morphe-data\" -Force


if (-not (Test-Path "morphe-data\morphe.keystore")) {

    Write-Host ""
    & "$JDK_PATH\bin\keytool.exe" -genkeypair `
      -keystore "morphe-data\morphe.keystore" `
      -alias Morphe `
      -keyalg RSA `
      -keysize 2048 `
      -validity 10000 `
      -storetype PKCS12 `
      -storepass dashi2 `
      -keypass dashi2 `
      -dname "CN=Morphe, OU=Android, O=Morphe, L=Unknown, ST=Unknown, C=US"

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERROR: Keystore generation failed."
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }

}


Write-Host ""

& "$JDK_PATH\bin\java.exe" -Xms1024M -Xmx1512M -Xss256k `
-jar "$PATCHER" patch --patches "$PATCHES_FILE" `
--keystore "morphe-data\morphe.keystore" `
--keystore-password "dashi2" `
--keystore-entry-alias "morphe" `
--keystore-entry-password "dashi2" `
-o "${INPUT_FILE}-patched.apk" --force `
-d "Alternative thumbnails" `
-d "Captions" `
-d "Change header" `
-d "Change installer source" `
-d "Clone app" `
-d "Custom branding" `
-d "Custom font" `
-d "DeArrow" `
-d "Downloads" `
-d "Enable debugging" `
-d "Network proxy" `
-d "PoToken provider" `
-d "Return YouTube Dislike" `
-d "Spoof video streams" `
-d "Theme" `
-d "Wide search bar" `
"$INPUT_FILE"

Write-Host ""
Read-Host "Press Enter to continue"

# Testing

# $JDK_PATH = "jdk-21.0.12.1+1"
# $PATCHER = "morphe-desktop-1.19.0-dev.5-all.jar"

# Remove-Item "morphe-data" -Recurse -Force
# New-Item -Path "morphe-data" -ItemType Directory -Force
# Copy-Item "config.json" "morphe-data\"
# New-Item -Path "morphe-data\libs" -ItemType Directory -Force
# Copy-Item "libs\*.jar" "morphe-data\libs\" -Force
# New-Item -Path "morphe-data\patches\MorpheApp-morphe-patches" -ItemType Directory -Force
# Copy-Item "patches-1.48.0-dev.12.mpp" "morphe-data\patches\MorpheApp-morphe-patches\" -Force

# & "$JDK_PATH\bin\java.exe" -Xms1024M -Xmx1512M -XX:+UseZGC -Xss256k -jar "$PATCHER"
