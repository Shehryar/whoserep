#!/bin/bash

FRAMEWORK_NAME="ASAPP.framework"
WORKING_DIR=$(pwd)
BUILD_DIR=$WORKING_DIR"/Build"
CARTHAGE_DIR=$WORKING_DIR"/Carthage"
CARTHAGE_FRAMEWORK_PATH=$CARTHAGE_DIR"/Build/iOS/"$FRAMEWORK_NAME
BUILD_FRAMEWORK_PATH=$BUILD_DIR"/"$FRAMEWORK_NAME

echo ""
echo "Working Directory: " $WORKING_DIR
echo "Build Directory: " $BUILD_DIR
echo "Carthage Directory: " $CARTHAGE_DIR

cd $WORKING_DIR

echo ""
echo "Cleaning Prior Builds"

rm -rf $CARTHAGE_DIR
rm -rf $BUILD_DIR

echo ""
echo "Building ASAPP Framework"

carthage build --no-skip-current

echo ""
echo ""

echo "Build succeeded. Copying to working directory"
cd $WORKING_DIR
mkdir $BUILD_DIR
cd $WORKING_DIR
# cp -r Carthage/Build/iOS/ASAPP.framework $BUILD_DIR"/ASAPP.framework"
cp -r $CARTHAGE_FRAMEWORK_PATH $BUILD_FRAMEWORK_PATH
cd $WORKING_DIR

echo ""
echo "Cleaning up mess"
rm -rf $CARTHAGE_DIR

echo "New framework available at: " $BUILD_FRAMEWORK_PATH
open -R $BUILD_FRAMEWORK_PATH