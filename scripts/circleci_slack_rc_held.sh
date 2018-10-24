#!/bin/bash

VERSION=$1
curl -X POST -H 'Content-type: application/json' --data '{ "text": "'"$VERSION"' release candidate is ready :outbox_tray:", "attachments": [ { "color": "#b37bd6", "text": "<https://circleci.com/workflow-run/'"$CIRCLE_WORKFLOW_ID"' | :double_vertical_bar: To distribute to QA, click `rc-approval`>" }, { "color": "#b37bd6", "text": "<https://circleci.com/workflow-run/'"$CIRCLE_WORKFLOW_ID"' | :double_vertical_bar: To create a release, click `release-approval`>" } ] }' https://hooks.slack.com/services/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

