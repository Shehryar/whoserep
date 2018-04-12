#!/bin/bash

bundle exec jazzy --clean --author ASAPP --author_url https://asapp.com --xcodebuild-arguments "-project,SDK/ASAPP.xcodeproj" --module ASAPP --output package/docs/swift --exclude=SDK/ASAPP/ASAPP/Components/Demo/* --readme package/docs/README.md

