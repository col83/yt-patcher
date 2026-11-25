
Set-Location $PSScriptRoot
Clear-Host

$PATCHER = "morphe-desktop-2.4.0-dev.4-all.jar"
if (-not (Test-Path $PATCHER)) {
    Write-Host ""
    Write-Host "ERROR: Patcher $PATCHER not exist."
    Write-Host ""
    Read-Host "Press Enter to continue"
    exit 2
}

$PATCHES_FILE = "patches-2.4.0-dev.12.mpp"
if (-not (Test-Path $PATCHES_FILE)) {
    Write-Host ""
    Write-Host "ERROR: Patches file $PATCHES_FILE not exist."
    Write-Host ""
    Read-Host "Press Enter to continue"
    exit 2
}

$JDK_PATH = "jdk-21.0.13.1+2"
if (-not (Test-Path $JDK_PATH)) {
    Write-Host ""
    Write-Host "ERROR: $JDK_PATH not exist."
    Write-Host ""
    Read-Host "Press Enter to continue"
    exit 2
}

$INPUT_FILE_NAME = "youtube"
$INPUT_FILE_VER = "20.26.46"
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
-e "Add to queue" `
-e "AI channel filter" `
-e "App refresh rate" `
-e "Autoplay control" `
-e "Bypass link redirects" `
-e "Change start page" `
-e "Comment search" `
-e "Copy text" `
-e "Copy video link" `
-e "Disable auto feed refresh" `
-e "Disable continue watching prompt" `
-e "Disable double tap actions" `
-e "Disable DRC audio" `
-e "Disable fullscreen gestures" `
-e "Disable haptic feedback" `
-e "Disable layout updates" `
-e "Disable player popup panels" `
-e "Disable QUIC protocol" `
-e "Disable rolling number animations" `
-e "Disable Shorts resuming on startup" `
-e "Disable sign in to TV popup" `
-e "Disable video codecs" `
-e "Enable debugging" `
-e "Force animations" `
-e "Force fullscreen landscape" `
-e "Force original audio" `
-e "Fullscreen video scale" `
-e "GmsCore support" `
-e "Hide ads" `
-e "Hide autoplay preview" `
-e "Hide end screen cards" `
-e "Hide end screen suggested video" `
-e "Hide info cards" `
-e "Hide layout components" `
-e "Hide player flyout menu components" `
-e "Hide player overlay buttons" `
-e "Hide Shorts components" `
-e "Hide video action buttons" `
-e "Loop video" `
-e "Miniplayer" `
-e "Open channel of live avatar" `
-e "Open links externally" `
-e "Open system share sheet" `
-e "Open videos fullscreen" `
-e "Override YouTube Music buttons" `
-e "Playback buffer" `
-e "Playlist button" `
-e "Playlist improvements" `
-e "Reload video" `
-e "Remove background playback restrictions" `
-e "Remove viewer discretion dialog" `
-e "Restore original titles" `
-e "Sanitize sharing links" `
-e "Save to Watch later" `
-e "Shorts autoplay" `
-e "Skip live Shorts" `
-e "SponsorBlock" `
-e "Spoof device dimensions" `
-e "Spoof video streams" `
-e "Video quality" `
--exclusive `
--keystore "morphe-data\morphe.keystore" --keystore-password "dashi2" --keystore-entry-alias "morphe" --keystore-entry-password "dashi2" `
--striplibs "arm64-v8a" `
-o "${INPUT_FILE}-patched.apk" --force `
"$INPUT_FILE"

Write-Host ""
Read-Host "Press Enter to continue"

# Testing

# $JDK_PATH = "jdk-21.0.13.1+2"
# $PATCHER = "morphe-desktop-2.4.0-dev.4-all.jar"

# Remove-Item "morphe-data" -Recurse -Force
# New-Item -Path "morphe-data" -ItemType Directory -Force

# New-Item -Path "morphe-data\libs" -ItemType Directory -Force
# Copy-Item "libs\*.jar" "morphe-data\libs\" -Force

# Copy-Item "config.json" "morphe-data\"

# New-Item -Path "morphe-data\patches\MorpheApp-morphe-patches" -ItemType Directory -Force
# Copy-Item "patches-2.4.0-dev.12.mpp" "morphe-data\patches\MorpheApp-morphe-patches\" -Force

# & "$JDK_PATH\bin\java.exe" -Xmx2G -XX:+UseLargePagesIndividualAllocation -XX:ReservedCodeCacheSize=512M -jar "%PATCHER%"
