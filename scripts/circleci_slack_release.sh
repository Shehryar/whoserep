#!/bin/bash

VERSION=$1
RELEASE_URL=$2
curl -X POST -H 'Content-type: application/json' --data '{ "text": "Release created for '"$VERSION"'.", "attachments": [ { "color": "#0fc400", "text": "<'"$RELEASE_URL"' | :octocat: View release>" } ] }' https://hooks.slack.com/services/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

