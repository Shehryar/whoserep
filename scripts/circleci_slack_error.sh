#!/bin/bash

TEXT=$1
curl -X POST -H 'Content-type: application/json' --data '{ "text": "'"$TEXT"'", "attachments": [ { "color": "#d10c21", "text": "<'"$CIRCLE_BUILD_URL"' | :mag: View build>" } ] }' https://hooks.slack.com/services/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

