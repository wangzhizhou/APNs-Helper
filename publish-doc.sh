# !/usr/bin/env bash
# -*- coding: utf-8 -*-
# reference: https://thisdevbrain.com/build-docc-documentation-using-command-line/

set -eu

if [ -z "$(git status --porcelain)" ];then
    git submodule init && git submodule update && git pull --recurse-submodules --ff-only
fi

CURRENT_COMMIT_HASH=`git rev-parse --short HEAD`

if [ ! -d website ]; then
    echo No website submodule
    exit -1
fi

cd website

git reset --hard HEAD && git fetch && git checkout main && git pull

if [ -d docs ]; then
    rm -rf docs
fi

if [ -d derivedData ]; then
    rm -rf derivedData
fi

xcodebuild docbuild \
    -project '../APNs Helper.xcodeproj' \
    -scheme 'APNs Helper Doc' \
    -sdk macosx \
    -destination=generic/platform=macOS \
    -derivedDataPath ./derivedData

PATH_TO_ARCHIVE_FILE=$(find ./derivedData -type d -name 'APNs Helper Doc.doccarchive')

if [ -z "$PATH_TO_ARCHIVE_FILE" ]; then
    echo no archive file found
    exit -1
fi

$(xcrun --find docc) process-archive \
transform-for-static-hosting "$PATH_TO_ARCHIVE_FILE" \
--hosting-base-path "APNs-Helper-Doc" \
--output-path ./docs

if [ -d derivedData ]; then
    rm -rf derivedData
fi

git add docs
if [ -n "$(git status --porcelain)" ]; then
    echo "Documentation changes found. Commiting the changes to the main branch and pushing to origin."
    git commit -m "Update GitHub Pages documentation site to '$CURRENT_COMMIT_HASH'."
    git push origin HEAD:main
else
  # No changes found, nothing to commit.
  echo "No documentation changes found."
fi