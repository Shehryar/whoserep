#!/bin/bash

open "SDK/Tests/Component UI Layout Tests"
echo -e "\n\n****************"
echo "Place .json files describing a Component View container in SDK/Tests/Component UI Layout Tests"
echo "Snapshots are generated in the Images directory."
echo "If you add a .json file and run snapshots.sh, the test runner will generate snapshots and report a failure."
echo "Run it again to have it validate the snapshots and succeed."
echo -e "****************\n\n"

xcodebuild test -quiet -workspace SDK/ASAPP.xcworkspace -scheme 'Component UI Layout Tests' -destination 'platform=iOS Simulator,OS=12.0,name=iPhone SE' SKIP_LINTING=1

