#!/bin/bash

if [ -n "${create_schema}" ]; then
    export CREATE_SCHEMA=false;
fi

if [ -z "${APP_NAME}" ]; then
    export APP_NAME="AD-Capital";
fi

if [ -z "${CONTROLLER}" ]; then
    export CONTROLLER="controller-ip-address";
fi

if [ -z "${APPD_PORT}" ]; then
    export APPD_PORT=8090;
fi

if [ -z "${EVENT_ENDPOINT}" ]; then
    export EVENT_ENDPOINT="event-service-ip-address:9080";
fi

if [ -z "${ACCOUNT_NAME}" ]; then
    export ACCOUNT_NAME="${ACCOUNT_NAME}";
fi

if [ -z "${ACCESS_KEY}" ]; then
    export ACCESS_KEY="account-access-key";
fi

if [ -n "${portal}" ]; then
    if [ -z "${NODE_NAME}" ]; then
      export NODE_NAME="AD-Capital_PORTAL_NODE";
    fi
    if [ -z "${TIER_NAME}" ]; then
      export TIER_NAME="Portal-Services";
    fi
fi

if [ -n "${rest}" ]; then
    if [ -z "${NODE_NAME}" ]; then
      export NODE_NAME="AD-Capital_REST_NODE";
    fi
    if [ -z "${TIER_NAME}" ]; then
      export TIER_NAME="Authentication-Services";
    fi
fi

if [ -n "${processor}" ]; then
    if [ -z "${NODE_NAME}" ]; then
        export NODE_NAME="AD-Capital_PROCESSOR_NODE";
    fi
    if [ -z "${TIER_NAME}" ]; then
        export TIER_NAME="LoanProcessor-Services";
    fi
fi

if [ -n "${queuereader}" ]; then
    if [ -z "${NODE_NAME}" ]; then
        export NODE_NAME="AD-Capital_QUEUEREADER_NODE";
    fi
    if [ -z "${TIER_NAME}" ]; then
        export TIER_NAME="QueueReader-Services";
    fi
fi

if [ -n "${verification}" ]; then
    if [ -z "${NODE_NAME}" ]; then
        export NODE_NAME="AD-Capital_VERIFICATION_NODE";
    fi
    if [ -z "${TIER_NAME}" ]; then
        export TIER_NAME="ApplicationProcessor-Services";
    fi
fi

# Set in Dockerfile based on installed App Server Agent version: _VERSION_STRING will be replaced during build
export VERSION_STRING="_VERSION_STRING"

export JAVA_OPTS="-Xmx512m -XX:MaxPermSize=256m"
export APPD_JAVA_OPTS="${JAVA_OPTS} -Dappdynamics.controller.hostName=${CONTROLLER} -Dappdynamics.controller.port=${APPD_PORT} -Dappdynamics.agent.applicationName=${APP_NAME} -Dappdynamics.agent.tierName=${TIER_NAME} -Dappdynamics.agent.nodeName=${NODE_NAME}";
export MACHINE_AGENT_JAVA_OPTS="-Dappdynamics.sim.enabled=true ${JAVA_OPTS} ${APPD_JAVA_OPTS}"
export APP_AGENT_JAVA_OPTS="${JAVA_OPTS} ${APPD_JAVA_OPTS} -DjvmRoute=${JVM_ROUTE} -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Dappdynamics.agent.accountName=${ACCOUNT_NAME%%_*} -Dappdynamics.agent.accountAccessKey=${ACCESS_KEY}";
export JMX_OPTS="-Dcom.sun.management.jmxremote.port=8888  -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
