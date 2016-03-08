# This script is provided for illustration purposes only.
#
# To build the ADCapital demo application, you will need to download the following components:
# 1. An appropriate version of the Oracle Java 7 JDK
#    (http://www.oracle.com/technetwork/java/javase/downloads/index.html)
# 2. Correct versions for the AppDynamics AppServer Agen and Analytics Agent for your Controller installation
#    (https://download.appdynamics.com)

#! /bin/bash

cleanUp() {
  if [ -z ${PREPARE_ONLY} ]; then 
    (cd ADCapital-Tomcat && rm -f AppServerAgent.zip MachineAgent.zip env.sh start-analytics.sh apache-tomcat-*.tar.gz Rest.war portal.war processor.war)
    (cd ADCapital-Tomcat && rm -rf AD-Capital)
    (cd ADCapital-ApplicationProcessor && rm -f AppServerAgent.zip MachineAgent.zip env.sh start-analytics.sh apache-tomcat-*.tar.gz Verification.jar)
    (cd ADCapital-ApplicationProcessor && rm -rf AD-Capital)
    (cd ADCapital-QueueReader && rm -f AppServerAgent.zip MachineAgent.zip env.sh start-analytics.sh apache-tomcat-*.tar.gz QueueReader.jar)
    (cd ADCapital-QueueReader && rm -rf AD-Capital)
    (cd ADCapital-Load && rm -rf AD-Capital-Load load-generator.zip)
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
  read -e -p "Enter path to Machine Agent (zip): " MACHINE_AGENT
  read -e -p "Enter path to Oracle JDK7: " ORACLE_JDK7
}

buildContainers() {
  echo; echo "Building ADCapital-Java..."
  (cd ADCapital-Java; docker build -t appdynamics/adcapital-java .) || exit $?

  echo; echo "Building ADCapital-Tomcat..."
  if [ -z ${LOCAL_BUILD} ]; then 
    (cd ADCapital-Tomcat && git clone https://github.com/Appdynamics/AD-Capital.git) || exit $?
    (cd ADCapital-Tomcat && docker build -t appdynamics/adcapital-tomcat .) || exit $?
  else
    (cp ${LOCAL_TOMCAT} ADCapital-Tomcat/apache-tomcat.tar.gz)
    (cp ${LOCAL_BUILD_PATH}/Rest/build/libs/Rest.war ADCapital-Tomcat/)
    (cp ${LOCAL_BUILD_PATH}/Portal/build/libs/portal.war ADCapital-Tomcat/)
    (cp ${LOCAL_BUILD_PATH}/Processor/build/libs/processor.war ADCapital-Tomcat/)
    (cd ADCapital-Tomcat && docker build --no-cache -f Dockerfile.local -t appdynamics/adcapital-tomcat .) || exit $?
  fi

  echo; echo "Building ADCapital-ApplicationProcessor..."
  if [ -z ${LOCAL_BUILD} ]; then 
    (cd ADCapital-ApplicationProcessor && git clone https://github.com/Appdynamics/AD-Capital.git) || exit $?
    (cd ADCapital-ApplicationProcessor && docker build -t appdynamics/adcapital-applicationprocessor .) || exit $?
  else
    (cp ${LOCAL_TOMCAT} ADCapital-ApplicationProcessor/apache-tomcat.tar.gz)
    (cp ${LOCAL_BUILD_PATH}/Verification/build/libs/Verification.jar ADCapital-ApplicationProcessor)
    (cd ADCapital-ApplicationProcessor && docker build -f Dockerfile.local -t appdynamics/adcapital-applicationprocessor .) || exit $?
  fi

  echo; echo "Building ADCapital-QueueReader..."
  if [ -z ${LOCAL_BUILD} ]; then 
    (cd ADCapital-QueueReader && git clone https://github.com/Appdynamics/AD-Capital.git) || exit $?
    (cd ADCapital-QueueReader && docker build -t appdynamics/adcapital-queuereader .) || exit $?
  else
    (cp ${LOCAL_TOMCAT} ADCapital-QueueReader/apache-tomcat.tar.gz)
    (cp ${LOCAL_BUILD_PATH}/QueueReader/build/libs/QueueReader.jar ADCapital-QueueReader)
    (cd ADCapital-QueueReader && docker build -f Dockerfile.local -t appdynamics/adcapital-queuereader .) || exit $?
  fi

  echo; echo "Building ADCapital-Load..."
  if [ -z ${LOCAL_LOAD_BUILD} ]; then 
    (cd ADCapital-Load && git clone https://github.com/Appdynamics/AD-Capital-Load.git) || exit $?
    (cd ADCapital-Load && docker build -t appdynamics/adcapital-load .) || exit $?
  else
    (cp ${LOCAL_LOAD_BUILD_PATH}/build/distributions/load-generator.zip ADCapital-Load)
    (cd ADCapital-Load && docker build -f Dockerfile.local -t appdynamics/adcapital-load .) || exit $?
  fi
}

# Usage information
if [[ $1 == *--help* ]]
then
  echo "Specify agent locations: build.sh
          -a <Path to App Server Agent>
          -m <Path to Machine Agent>
          [-j <Path to Oracle JDK7>]
          [-b <Path to local AD-Capital build>]
          [-l <Path to local AD-Capital-Load build>]
          [-t <Path to local Tomcat gzip distro>]"
  echo "Prompt for agent locations: build.sh"
  exit 0
fi

# Prompt for location of App Server, Machine and Database Agents
if  [ $# -eq 0 ]
then
  promptForAgents
else
  # Allow user to specify locations of App Server and Analytics Agents
  while getopts "a:m:j:b:l:p:t:" opt; do
    case $opt in
      a)
        APP_SERVER_AGENT=$OPTARG
        if [ ! -e ${APP_SERVER_AGENT} ]; then
          echo "Not found: ${APP_SERVER_AGENT}"; exit
        fi
        ;;
      m)
        MACHINE_AGENT=$OPTARG 
	if [ ! -e ${MACHINE_AGENT} ]; then
          echo "Not found: ${MACHINE_AGENT}"; exit         
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
      b)
        LOCAL_BUILD_PATH=$OPTARG
        echo "Using local Gradle build (AD-Capital) from: ${LOCAL_BUILD_PATH}"
        LOCAL_BUILD=true;
        ;;
      t)
        LOCAL_TOMCAT=$OPTARG
        echo "Using local Tomcat archive: ${LOCAL_TOMCAT}"
        LOCAL_BUILD=true;
        ;;
      l)
        LOCAL_LOAD_BUILD_PATH=$OPTARG
        echo "Using local Gradle build (AD-Capital-Load) from: ${LOCAL_LOAD_BUILD_PATH}"
        LOCAL_LOAD_BUILD=true;
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

if [ -z ${MACHINE_AGENT} ]; then
    echo "Error: Analytics Agent is required"; exit
fi

if [ "${LOCAL_BUILD}" = true ]; then
  if [ ! -d ${LOCAL_BUILD_PATH} ]; then
    echo "Error: ${LOCAL_BUILD_PATH} does not exist"; exit
  fi 
  if [ ! -f ${LOCAL_TOMCAT} ]; then
    echo "Error: ${LOCAL_TOMCAT} does not exist"; exit
  fi 
fi

if [ -z ${ORACLE_JDK7} ]
then
    echo "Downloading Oracle Java 7 JDK"
    (cd ADCapital-Java; curl -j -k -L -H "Cookie:oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u71-b13/jdk-7u71-linux-x64.rpm -o jdk-linux-x64.rpm) || exit $?
else
    echo "Using JDK: ${ORACLE_JDK7}"
    cp ${ORACLE_JDK7} ADCapital-Java/jdk-linux-x64.rpm
fi

# Add Analytics config to build
cp start-analytics.sh ADCapital-Tomcat
cp start-analytics.sh ADCapital-ApplicationProcessor
cp start-analytics.sh ADCapital-QueueReader

# Add machine agent to build
cp ${MACHINE_AGENT} ADCapital-Tomcat/MachineAgent.zip
cp ${MACHINE_AGENT} ADCapital-ApplicationProcessor/MachineAgent.zip
cp ${MACHINE_AGENT} ADCapital-QueueReader/MachineAgent.zip

# Add App Server Agent to build
cp ${APP_SERVER_AGENT} ADCapital-Tomcat/AppServerAgent.zip
cp ${APP_SERVER_AGENT} ADCapital-ApplicationProcessor/AppServerAgent.zip
cp ${APP_SERVER_AGENT} ADCapital-QueueReader/AppServerAgent.zip

# Add common environment to build
cp env.sh ADCapital-Tomcat
cp env.sh ADCapital-ApplicationProcessor
cp env.sh ADCapital-QueueReader

# Skip build if -p flag (Prepare only) set
if [ "${PREPARE_ONLY}" = true ] ; then
    echo "Skipping build phase"
else
    buildContainers
fi
