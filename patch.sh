
#!/usr/bin/bash
set -Eeu
clear

if ! command -v jq &>/dev/null; then
    echo; echo "ERROR: 'jq' not found."; echo
    exit 2
fi


UPDATE_CHANNEL="dev" # main, dev
UPDATE_JSON="$(curl -fsSL https://raw.githubusercontent.com/MorpheApp/morphe-patches/${UPDATE_CHANNEL}/patches-bundle.json)"

PATCHER="morphe-desktop-2.4.0-dev.4-all.jar"
if [ ! -f "${PATCHER}" ]; then
    echo; echo "ERROR: Patcher '${PATCHER}' not exist."; echo
    exit 2
fi

PATCHES_VER="$(jq -r '.version' <<< "$UPDATE_JSON")"

# test redefine
PATCHES_VER="2.4.0-dev.12"

PATCHES_FILE_URL="$(jq -r '.download_url' <<< "$UPDATE_JSON")"
# PATCHES_FILE_URL="https://github.com/MorpheApp/morphe-patches/releases/download/v${PATCHES_VER}/patches-${PATCHES_VER}.mpp"

PATCHES_FILE="patches-${PATCHES_VER}.mpp"
if [ ! -f "${PATCHES_FILE}" ]; then
    echo; echo "ERROR: Patches file '${PATCHES_FILE}' not exist."; echo
    exit 2
fi

JDK_PATH="jdk-21.0.13.1+2"
if [ ! -d "${JDK_PATH}" ]; then
    echo; echo "ERROR: ${JDK_PATH} not exist."; echo
    exit 2
fi

INPUT_FILE_NAME="youtube"
INPUT_FILE_VER=20.26.46
INPUT_FILE="${INPUT_FILE_NAME}_${INPUT_FILE_VER}.apk"
if [ ! -f "${INPUT_FILE}" ]; then
    echo; echo "ERROR: input file '${INPUT_FILE}' not exist."; echo
    exit 2
fi


echo
echo "VERSION: ${PATCHES_VER}"
echo "URL: ${PATCHES_FILE_URL}"
echo "FILE: ${PATCHES_FILE}"


mkdir -p "morphe-data/libs"
cp -R "libs/" "morphe-data/"
cp -f "config.json" "morphe-data/"


if [ ! -f "morphe-data/morphe.keystore" ]; then
    "${JDK_PATH}/bin/keytool" -genkeypair \
        -keystore "morphe-data/morphe.keystore" \
        -alias Morphe \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -storetype PKCS12 \
        -storepass dashi2 \
        -keypass dashi2 \
        -dname "CN=Morphe, OU=Android, O=Morphe, L=Unknown, ST=Unknown, C=US"
fi


echo
"${JDK_PATH}/bin/java" -Xms1024M -Xmx1512M -Xss256k -XX:ReservedCodeCacheSize=512M \
  -jar "${PATCHER}" patch --patches "${PATCHES_FILE}" \
  -e "Add to queue" \
  -e "AI channel filter" \
  -e "App refresh rate" \
  -e "Autoplay control" \
  -e "Bypass link redirects" \
  -e "Change start page" \
  -e "Comment search" \
  -e "Copy text" \
  -e "Copy video link" \
  -e "Disable auto feed refresh" \
  -e "Disable continue watching prompt" \
  -e "Disable double tap actions" \
  -e "Disable DRC audio" \
  -e "Disable fullscreen gestures" \
  -e "Disable haptic feedback" \
  -e "Disable layout updates" \
  -e "Disable player popup panels" \
  -e "Disable QUIC protocol" \
  -e "Disable rolling number animations" \
  -e "Disable Shorts resuming on startup" \
  -e "Disable sign in to TV popup" \
  -e "Disable video codecs" \
  -e "Enable debugging" \
  -e "Force animations" \
  -e "Force fullscreen landscape" \
  -e "Force original audio" \
  -e "Fullscreen video scale" \
  -e "GmsCore support" \
  -e "Hide ads" \
  -e "Hide autoplay preview" \
  -e "Hide end screen cards" \
  -e "Hide end screen suggested video" \
  -e "Hide info cards" \
  -e "Hide layout components" \
  -e "Hide player flyout menu components" \
  -e "Hide player overlay buttons" \
  -e "Hide Shorts components" \
  -e "Hide video action buttons" \
  -e "Loop video" \
  -e "Miniplayer" \
  -e "Open channel of live avatar" \
  -e "Open links externally" \
  -e "Open system share sheet" \
  -e "Open videos fullscreen" \
  -e "Override YouTube Music buttons" \
  -e "Playback buffer" \
  -e "Playlist button" \
  -e "Playlist improvements" \
  -e "Reload video" \
  -e "Remove background playback restrictions" \
  -e "Remove viewer discretion dialog" \
  -e "Restore original titles" \
  -e "Sanitize sharing links" \
  -e "Save to Watch later" \
  -e "Shorts autoplay" \
  -e "Skip live Shorts" \
  -e "SponsorBlock" \
  -e "Spoof device dimensions" \
  -e "Spoof video streams" \
  -e "Video quality" \
  --exclusive \
  --keystore "morphe-data/morphe.keystore" --keystore-password "dashi2" --keystore-entry-alias "morphe" --keystore-entry-password "dashi2" \
  --striplibs "arm64-v8a" \
  -o "${INPUT_FILE}-patched.apk" --force \
  "${INPUT_FILE}"

echo

# Testing

# JDK_PATH="jdk-21.0.13.1+2"
# PATCHER="morphe-desktop-2.4.0-dev.4-all.jar"

# rm -rf "morphe-data"
# mkdir "morphe-data"

# cp -R "libs/" "morphe-data/"

# cp "config.json" "morphe-data/"

# mkdir "morphe-data/patches/MorpheApp-morphe-patches/"
# cp "patches-2.4.0-dev.12.mpp" "morphe-data/patches/MorpheApp-morphe-patches/"

# "%JDK_PATH%\bin\java.exe" -Xmx2G -XX:+UseLargePagesIndividualAllocation -XX:ReservedCodeCacheSize=512M -jar "%PATCHER%"
