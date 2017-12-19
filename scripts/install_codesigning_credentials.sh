#!/bin/bash

security create-keychain -p circle circle.keychain
security set-keychain-settings -t 72000 circle.keychain
security unlock-keychain -p circle circle.keychain
security list-keychains -d user -s login.keychain circle.keychain
security default-keychain -s circle.keychain
security import Provisioning/ASAPP\ Dev\ Certificates.p12 -k circle.keychain -P $ASAPP_P12_PASSWORD -T /usr/bin/codesign -T /usr/bin/security
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles/
cp -v Provisioning/*.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k circle circle.keychain
security find-identity -p codesigning

