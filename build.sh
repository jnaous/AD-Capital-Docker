# This script is provided for illustration purposes only.
#
# To build the ECommerce demo application, you will need to download the following components:
# 1. An appropriate version of the Oracle Java 7 JDK
#    (http://www.oracle.com/technetwork/java/javase/downloads/index.html)
# 2. Correct versions for the AppDynamics AppServer Agen and Analytics Agent for your Controller installation
#    (https://download.appdynamics.com)

#! /bin/bash

cleanUp() {
  (cd ADCapital-Tomcat && rm -f AppServerAgent.zip AnalyticsAgent.zip)
  (cd ADCapital-Tomcat && rm -rf AD-Capital)
  (cd ADCapital-ApplicationProcessor && rm -f AppServerAgent.zip AnalyticsAgent.zip)
  (cd ADCapital-ApplicationProcessor && rm -rf AD-Capital)
  (cd ADCapital-Java && rm -f jdk-linux-x64.rpm)
  # Remove dangling images left-over from build
  if [[ `docker images -q --filter "dangling=true"` ]]
  then
    echo
    echo "Deleting intermediate containers..."
    docker images -q --filter "dangling=true" | xargs docker rmi;
  fi
}
trap cleanUp EXIT
promptForAgents() {
  read -e -p "Enter path to App Server Agent: " APP_SERVER_AGENT
  read -e -p "Enter path to Analytics Agent: " ANALYTICS_AGENT
  read -e -p "Enter path to Oracle JDK7: " ORACLE_JDK7
}

# Prompt for location of App Server, Machine and Database Agents
if  [ $# -eq 0 ]
then
  promptForAgents
fi

if [ -z ${APP_SERVER_AGENT} ]; then
    echo "Error: App Server Agent is required"; exit
fi

if [ -z ${ANALYTICS_AGENT} ]; then
    echo "Error: Javascript Agent is required"; exit
fi


if [ -z ${ORACLE_JDK7} ]
then
    echo "Downloading Oracle Java 7 JDK"
    (cd ADCapital-Java; curl -j -k -L -H "Cookie:oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u71-b13/jdk-7u71-linux-x64.rpm -o jdk-linux-x64.rpm)
else
    echo "Using JDK: ${ORACLE_JDK7}"
    cp ${ORACLE_JDK7} ADCapital-Java/jdk-linux-x64.rpm
fi

echo "Building ADCapital-Java..."
(cd ADCapital-Java; docker build -t appdynamics/adcapital-java .)
echo

# If supplied, add standalone analytics agent to build
if [ -z ${ANALYTICS_AGENT} ]
then
    echo "Skipping standalone Analytics Agent install"
else
    echo "Installing standalone Analytics Agent"
    echo "  ${ANALYTICS_AGENT}"
    cp ${ANALYTICS_AGENT} ADCapital-Tomcat/AnalyticsAgent.zip
    cp ${ANALYTICS_AGENT} ADCapital-ApplicationProcessor/AnalyticsAgent.zip

    # Add analytics agent when creating Dockerfile for machine agent
    DOCKERFILE_OPTIONS="analytics"
fi

cp ${APP_SERVER_AGENT} ADCapital-Tomcat/AppServerAgent.zip
echo "Copied Agents for ADCapital-Tomcat"

cp ${APP_SERVER_AGENT} ADCapital-ApplicationProcessor/AppServerAgent.zip
echo "Copied Agents for ADCapital-ApplicationProcessor"

echo; echo "Building ADCapital-Tomcat..."
(cd ADCapital-Tomcat && git clone https://github.com/Appdynamics/AD-Capital.git)
(cd ADCapital-Tomcat && docker build -t appdynamics/adcapital-tomcat .)

echo; echo "Building ADCapital-ApplicationProcessor..."
(cd ADCapital-ApplicationProcessor && git clone https://github.com/Appdynamics/AD-Capital.git)
(cd ADCapital-ApplicationProcessor && docker build -t appdynamics/adcapital-applicationprocessor .)
