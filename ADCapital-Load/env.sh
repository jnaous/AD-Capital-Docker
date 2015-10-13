#! /bin/bash

# 1st param to LoadRunner call
if [ -z "${PORTAL_URL}" ]; then
        export PORTAL_URL="portal";
fi

# 2nd param to LoadRunner call
if [ -z "${PROCESSOR_URL}" ]; then
        export PROCESSOR_URL="processor";
fi
