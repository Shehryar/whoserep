#!/bin/sh

if [ -z "$XCODE_VERSION_CORRECT" ]
then
    export SUDO_ASKPASS="${PROJECT_DIR}/../scripts/askpass.sh"
fi

UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# Step 1. Build Device and Simulator versions
# add BITCODE_GENERATION_MODE=bitcode to support bitcode
echo "Building for devices"
xcodebuild -target "${PROJECT_NAME}" -configuration ${CONFIGURATION} -sdk iphoneos ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build

# add BITCODE_GENERATION_MODE=marker to support bitcode
echo "Building for simulators"
xcodebuild -target "${PROJECT_NAME}" -configuration ${CONFIGURATION} -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build

# Step 2. Copy the framework structure (from iphoneos build) to the universal folder
echo "Copying framework structure"
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 3. Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
echo "Copying simulator Swift modules"
SIMULATOR_SWIFT_MODULES_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/."
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"
fi

# Step 4. Create universal binary file using lipo and place the combined executable in the copied framework directory
echo "Creating universal binary using lipo"
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework/${PROJECT_NAME}"

# Step 5. Convenience step to copy the framework to the project's directory
cp -R "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework" "${PROJECT_DIR}/../package/"

# Step 6. Convenience step to open the project's directory in Finder
open "${PROJECT_DIR}/../package/"

