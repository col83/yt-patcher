#!/usr/bin/bash
set -Eeu
clear

if ! command -v jq &>/dev/null; then
    echo; echo "ERROR: 'jq' not found."; echo
    exit 2
fi


UPDATE_CHANNEL="dev" # main, dev
UPDATE_JSON="$(curl -fsSL https://raw.githubusercontent.com/MorpheApp/morphe-patches/${UPDATE_CHANNEL}/patches-bundle.json)"

PATCHER="morphe-desktop-1.19.0-dev.5-all.jar"
if [ ! -f "${PATCHER}" ]; then
    echo; echo "ERROR: Patcher '${PATCHER}' not exist."; echo
    exit 2
fi

PATCHES_VER="$(jq -r '.version' <<< "$UPDATE_JSON")"

# test redefine
PATCHES_VER="1.48.0-dev.12"

PATCHES_FILE_URL="$(jq -r '.download_url' <<< "$UPDATE_JSON")"
# PATCHES_FILE_URL="https://github.com/MorpheApp/morphe-patches/releases/download/v${PATCHES_VER}/patches-${PATCHES_VER}.mpp"

PATCHES_FILE="patches-${PATCHES_VER}.mpp"
if [ ! -f "${PATCHES_FILE}" ]; then
    echo; echo "ERROR: Patches file '${PATCHES_FILE}' not exist."; echo
    exit 2
fi

JDK_PATH="jdk-21.0.12.1+1"
if [ ! -d "${JDK_PATH}" ]; then
    echo; echo "ERROR: ${JDK_PATH} not exist."; echo
    exit 2
fi

INPUT_FILE_NAME="youtube"
INPUT_FILE_VER=21.20.405
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


clear
echo
"${JDK_PATH}/bin/java" -Xms1024M -Xmx1512M -Xss256k \
  -jar "${PATCHER}" patch --patches "${PATCHES_FILE}" \
  --keystore "morphe-data/morphe.keystore" \
  --keystore-password "dashi2" \
  --keystore-entry-alias "morphe" \
  --keystore-entry-password "dashi2" \
  -o "${INPUT_FILE}-patched.apk" --force \
  -d "Alternative thumbnails" \
  -d "Captions" \
  -d "Change header" \
  -d "Change installer source" \
  -d "Clone app" \
  -d "Custom branding" \
  -d "Custom font" \
  -d "DeArrow" \
  -d "Downloads" \
  -d "Enable debugging" \
  -d "Network proxy" \
  -d "PoToken provider" \
  -d "Return YouTube Dislike" \
  -d "Spoof video streams" \
  -d "Theme" \
  -d "Wide search bar" \
  "${INPUT_FILE}.apk"

echo

# Testing

# JDK_PATH="jdk-21.0.12.1+1"
# PATCHER="morphe-desktop-1.19.0-dev.5-all.jar"

# rm -rf "morphe-data"
# mkdir "morphe-data"
# cp -R "libs/" "morphe-data/"
# cp "config.json" "morphe-data/"
# mkdir "morphe-data/patches/MorpheApp-morphe-patches/"
# cp "patches-1.48.0-dev.12.mpp" "morphe-data/patches/MorpheApp-morphe-patches/"

# "%JDK_PATH%\bin\java.exe" -Xms1024M -Xmx1512M -XX:+UseZGC -Xss256k -jar "%PATCHER%"
