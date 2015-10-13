# This script is provided for illustration purposes only.
#
# To build the ECommerce demo application, you will need to download the following components:
# 1. An appropriate version of the Oracle Java 7 JDK
#    (http://www.oracle.com/technetwork/java/javase/downloads/index.html)
# 2. Correct versions for the AppDynamics AppServer Agen and Analytics Agent for your Controller installation
#    (https://download.appdynamics.com)

#! /bin/bash

cleanUp() {
  if [ -z ${PREPARE_ONLY} ]; then 
    (cd ADCapital-Tomcat && rm -f AppServerAgent.zip AnalyticsAgent.zip env.sh start-analytics.sh)
    (cd ADCapital-Tomcat && rm -rf AD-Capital)
    (cd ADCapital-ApplicationProcessor && rm -f AppServerAgent.zip AnalyticsAgent.zip env.sh start-analytics.sh)
    (cd ADCapital-ApplicationProcessor && rm -rf AD-Capital)
    (cd ADCapital-QueueReader && rm -f AppServerAgent.zip AnalyticsAgent.zip env.sh start-analytics.sh)
    (cd ADCapital-QueueReader && rm -rf AD-Capital)
    (cd ADCapital-Load && rm -rf AD-Capital-Load)
    (cd ADCapital-Java && rm -f jdk-linux-x64.rpm)
  fi

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

buildContainers() {
  echo; echo "Building ADCapital-Java..."
  (cd ADCapital-Java; docker build -t appdynamics/adcapital-java .)

  echo; echo "Building ADCapital-Tomcat..."
  (cd ADCapital-Tomcat && git clone https://github.com/Appdynamics/AD-Capital.git)
  (cd ADCapital-Tomcat && docker build -t appdynamics/adcapital-tomcat .)

  echo; echo "Building ADCapital-ApplicationProcessor..."
  (cd ADCapital-ApplicationProcessor && git clone https://github.com/Appdynamics/AD-Capital.git)
  (cd ADCapital-ApplicationProcessor && docker build -t appdynamics/adcapital-applicationprocessor .)

  echo; echo "Building ADCapital-QueueReader..."
  (cd ADCapital-QueueReader && git clone https://github.com/Appdynamics/AD-Capital.git)
  (cd ADCapital-QueueReader && docker build -t appdynamics/adcapital-queuereader .)

  echo; echo "Building ADCapital-Load..."
  (cd ADCapital-Load && git clone https://github.com/Appdynamics/AD-Capital-Load.git)
  (cd ADCapital-Load && docker build -t appdynamics/adcapital-load .)
}

# Prompt for location of App Server, Machine and Database Agents
if  [ $# -eq 0 ]
then
  promptForAgents
else
  # Allow user to specify locations of App Server and Analytics Agents
  while getopts "a:y:j:p:" opt; do
    case $opt in
      a)
        APP_SERVER_AGENT=$OPTARG
        if [ ! -e ${APP_SERVER_AGENT} ]; then
          echo "Not found: ${APP_SERVER_AGENT}"; exit
        fi
        ;;
      y)
        ANALYTICS_AGENT=$OPTARG 
	if [ ! -e ${ANALYTICS_AGENT} ]; then
          echo "Not found: ${ANALYTICS_AGENT}"; exit         
        fi
        ;;
      j)
        ORACLE_JDK7=$OPTARG
        if [ ! -e ${ORACLE_JDK7} ]; then
          echo "Not found: ${ORACLE_JDK7}"; exit
        fi
        ;; 
      p)
        echo "Prepare build environment only - no docker builds"
        PREPARE_ONLY=true;
        ;;
      \?)
        echo "Invalid option: -$OPTARG"
        ;;
    esac
  done
fi

if [ -z ${APP_SERVER_AGENT} ]; then
    echo "Error: App Server Agent is required"; exit
fi

if [ -z ${ANALYTICS_AGENT} ]; then
    echo "Error: Analytics Agent is required"; exit
fi

if [ -z ${ORACLE_JDK7} ]
then
    echo "Downloading Oracle Java 7 JDK"
    (cd ADCapital-Java; curl -j -k -L -H "Cookie:oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u71-b13/jdk-7u71-linux-x64.rpm -o jdk-linux-x64.rpm)
else
    echo "Using JDK: ${ORACLE_JDK7}"
    cp ${ORACLE_JDK7} ADCapital-Java/jdk-linux-x64.rpm
fi

# If supplied, add standalone analytics agent to build
if [ -z ${ANALYTICS_AGENT} ]
then
    echo "Skipping standalone Analytics Agent install"
else
    echo "Installing standalone Analytics Agent"
    echo "  ${ANALYTICS_AGENT}"
    cp ${ANALYTICS_AGENT} ADCapital-Tomcat/AnalyticsAgent.zip
    cp ${ANALYTICS_AGENT} ADCapital-ApplicationProcessor/AnalyticsAgent.zip
    cp ${ANALYTICS_AGENT} ADCapital-QueueReader/AnalyticsAgent.zip

    cp start-analytics.sh ADCapital-Tomcat
    cp start-analytics.sh ADCapital-ApplicationProcessor
    cp start-analytics.sh ADCapital-QueueReader

    # Add analytics agent when creating Dockerfile for machine agent
    DOCKERFILE_OPTIONS="analytics"
fi

echo "Installing App Server Agent"
echo " ${APP_SERVER_AGENT}"
cp ${APP_SERVER_AGENT} ADCapital-Tomcat/AppServerAgent.zip
cp ${APP_SERVER_AGENT} ADCapital-ApplicationProcessor/AppServerAgent.zip
cp ${APP_SERVER_AGENT} ADCapital-QueueReader/AppServerAgent.zip

echo "Copying environment settings for containers"
cp env.sh ADCapital-Tomcat
cp env.sh ADCapital-ApplicationProcessor
cp env.sh ADCapital-QueueReader

# Skip build if -p flag (Prepare only) set
if [ "${PREPARE_ONLY}" = true ] ; then
    echo "Skipping build phase"
else
    buildContainers
fi
