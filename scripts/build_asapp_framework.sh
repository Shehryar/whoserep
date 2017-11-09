#!/bin/bash

PACKAGE_DIR=$(pwd)"/package"
PACKAGE_FRAMEWORK_PATH=$PACKAGE_DIR"/"$FRAMEWORK_NAME
TEMP_BUILD_DIR=".temp_sdk_build"

cp -r SDK "$TEMP_BUILD_DIR"
cd "$TEMP_BUILD_DIR"

# remove dependencies not used in framework, currently all of them,
# so Carthage doesn't waste time building them
rm -f Cartfile.*

FRAMEWORK_NAME="ASAPP.framework"
WORKING_DIR=$(pwd)
BUILD_DIR=$WORKING_DIR"/Build"
CARTHAGE_DIR=$WORKING_DIR"/Carthage"
CARTHAGE_BUILD_DIR=$CARTHAGE_DIR"/Build"
CARTHAGE_FRAMEWORK_PATH=$CARTHAGE_BUILD_DIR"/iOS/"$FRAMEWORK_NAME
BUILD_FRAMEWORK_PATH=$BUILD_DIR"/"$FRAMEWORK_NAME

reminder="Run this script in the parent directory of SDK.\nTried to run in $(pwd)\n"

if [ ! -d "$BUILD_DIR" ]; then
	echo "here: $BUILD_DIR"
	echo -e "Build directory not found. $reminder"
	exit
fi

if [ ! -d "$CARTHAGE_DIR" ]; then
	echo -e "Carthage directory not found. $reminder"
	exit
fi

if [ ! -d "$CARTHAGE_BUILD_DIR" ]; then
	echo -e "Carthage/Build directory not found. $reminder"
	exit
fi

if [ ! -d "$PACKAGE_DIR" ]; then
	echo -e "package directory not found. $reminder"
	exit
fi

echo ""
echo "Working Directory: $WORKING_DIR"
echo "Build Directory: $BUILD_DIR"
echo "Carthage Directory: $CARTHAGE_DIR"

echo -e "\nCleaning Prior Builds"

rm -rf "$CARTHAGE_BUILD_DIR"
rm -rf "$BUILD_DIR"
rm -rf "$CARTHAGE_DIR/Checkouts"

echo -e "\nBuilding ASAPP Framework"

carthage build --no-skip-current

echo -e "\n\nBuild succeeded. Copying to working directory"

cd "$WORKING_DIR"
mkdir "$BUILD_DIR"
cd "$WORKING_DIR"
cp -r "$CARTHAGE_FRAMEWORK_PATH" "$BUILD_FRAMEWORK_PATH"
cd "$WORKING_DIR"

cp -r "$CARTHAGE_FRAMEWORK_PATH" "$PACKAGE_FRAMEWORK_PATH"

cd ../
rm -rf "$TEMP_BUILD_DIR"
rm -rf "$TEMP_BUILD_DIR.xcarchive"

echo "New framework available at: $PACKAGE_FRAMEWORK_PATH"
open -R "$PACKAGE_FRAMEWORK_PATH"
