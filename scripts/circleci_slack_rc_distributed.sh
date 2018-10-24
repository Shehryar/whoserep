#!/bin/bash

BUILD_NUMBER=$1
curl -X POST -H 'Content-type: application/json' --data '{ "text": "'"$CIRCLE_BRANCH"' has been distributed to testers as build '"$BUILD_NUMBER"' :sparkles:", "attachments": [ {"color": "#008bfb", "text": "<https://www.fabric.io/asapp/ios/apps/com.asappinc.testapp/beta/releases/latest | :mag: View latest beta on Fabric>"}, {"color": "#00cc84", "text": "<'"$CIRCLE_BUILD_URL"' | :book: View CircleCI build>"} ] }' https://hooks.slack.com/services/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

