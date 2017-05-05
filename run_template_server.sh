#!/bin/bash

WORKING_DIR=$(pwd)
SERVER_PATH=$WORKING_DIR"/template-server"
ESCAPED_SERVER_PATH=$(printf %q "$SERVER_PATH")
SERVER_NAME="server.js"

cd $ESCAPED_SERVER_PATH

echo "Running Node Server: " $SERVER_NAME

node $SERVER_NAME