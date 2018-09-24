#!/bin/bash

# Based on https://forum.juce.com/t/build-script-for-automatically-moving-built-aus-into-components-folder-xcode/13112
# To use sudo -A in an Xcode build script, create a new Keychain and add a new item:
#   Item Name: XcodeSudoPassword
#   Account Name: sudo
#   Password: <your sudo password>
# Then make sure your build script points to this file with
#   export SUDO_ASKPASS="${PROJECT_DIR}/../scripts/askpass.sh"

/usr/bin/security find-generic-password -l XcodeSudoPassword -a sudo -w

