#!/usr/bin/env sh
GITHUB_URL="https://github.com/tid-kijyun/Kanna"
POD_NAME=Kanna
PODSPEC=Kanna.podspec
REMOTE_BRANCH=master
MAIN_PLIST_PATH=Sources/Kanna/Info.plist
TEST_PLIST_PATH=Tests/KannaTests/Info.plist
README=README.md

POD=${COCOAPODS:-pod}

function help {
    echo "Usage: release VERSION RELEASE_NOTES [-f]"
    echo
    exit 1
}

function die {
    echo "[ERROR] $@"
    echo
    exit 1
}

if [ $# -lt 2 ]; then
    help
fi

VERSION=$1
FORCE_TAG=$3
VERSION_TAG="$VERSION"

echo $VERSION_TAG | grep -q -E "^\d+\.\d+\.\d+(-\w+(\.\d)?)?\$"
if [ $? -ne 0 ]; then
    die "This tag ($VERSION) is an incorrect format. It should be in '{MAJOR}.{MINOR}.{PATCH}(-{PRERELEASE_NAME}.{PRERELEASE_VERSION})' form."
fi

echo "Is this tag ($VERSION) unique?"
git describe --tags "$VERSION_TAG" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    if [ -z "$FORCE_TAG" ]; then
        die "This tag ($VERSION) already exists. Aborting. Append '-f' to override."
    else
        echo " > No, but force was specified."
    fi
else
    echo " > Yes, tag is unique."
fi

if [ ! -f "$PODSPEC" ]; then
    die "Cannot find podspec: $PODSPEC. Aborting."
fi

if [ ! -f "$MAIN_PLIST_PATH" ]; then
    die "Cannot find plist: $MAIN_PLIST_PATH. Aborting."
fi

if [ ! -f "$TEST_PLIST_PATH" ]; then
  die "Cannot find plist: $TEST_PLIST_PATH. Aborting."
fi

echo "Verified ownership to $POD_NAME pod"
pod trunk me | grep -q "$POD_NAME" || die "You don't have access to pod repository $POD_NAME. Aborting."
echo " > OK"

echo "Releasing version $VERSION (tag: $VERSION_TAG)..."

git fetch origin || die "Failed to fetch origin"
git diff --quiet HEAD "origin/$REMOTE_BRANCH" || die "HEAD is not aligned to origin/$REMOTE_BRANCH. Cannot update version safely"

echo "Setting podspec version"
cat "$PODSPEC" | grep "s.version" | grep -q "\"$VERSION\""
SET_PODSPEC_VERSION=$?
if [ $SET_PODSPEC_VERSION -eq 0 ]; then
    echo " > Podspec already set to $VERSION. Skinpping."
else
    echo " > Setting..."
    sed -i.backup "s/s.version *= *\".*\"/s.version          = \"$VERSION\"/g" "$PODSPEC" || {
        restore_podspec
        die "Failed to update version in podspec"
    }
fi

# rewrite plist
echo "Setting CFBundleShortVersionString to plist"
plutil -replace 'CFBundleShortVersionString' -string "${VERSION}" ${MAIN_PLIST_PATH}
plutil -replace 'CFBundleShortVersionString' -string "${VERSION}" ${TEST_PLIST_PATH}

rm ${PODSPEC}.backup
rm ${MAIN_PLIST_PATH}.backup
rm ${TEST_PLIST_PATH}.backup

git add ${PODSPEC} ${MAIN_PLIST_PATH} ${TEST_PLIST_PATH} ${README} || { restore_podspec; die "Failed to add ${PODSPEC} to INDEX"; }
git commit -m "Bumping version to $VERSION" || { restore_podspec; die "Failed to push updated version: $VERSION"; }
git tag "$VERSION_TAG" || die "Failed to tag version"
git push origin "$VERSION_TAG" || die "Failed to push tag '$VERSION_TAG' to origin"
git push

echo ${GITHUB_URL}/releases/new?tag=${VERSION_TAG}

echo "Pushing to Cocoapods"
pod trunk push
