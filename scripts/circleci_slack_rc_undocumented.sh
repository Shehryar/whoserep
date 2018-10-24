#!/bin/bash

curl -X POST -H 'Content-type: application/json' --data '{ "text": ":warning: '"$CIRCLE_BRANCH"' has undocumented symbols!", "attachments": [ { "color": "#ff4e56", "text": "<'"$CIRCLE_BUILD_URL"' | :mag: View build>" } ] }' https://hooks.slack.com/services/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

