#!/bin/bash

WORKING_DIR=$(pwd)
SERVER_PATH=$WORKING_DIR"/ASAPP/ASAPP/Components/Demo/JSON/"
ESCAPED_SERVER_PATH=$(printf %q "$SERVER_PATH")
SERVER_NAME="component_server.js"

echo "Moving to directory: " $ESCAPED_SERVER_PATH
cd $ESCAPED_SERVER_PATH

echo "Running Node Server: " $SERVER_NAME
echo ""

node $SERVER_NAME