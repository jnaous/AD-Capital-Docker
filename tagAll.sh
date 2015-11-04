#! /bin/bash

if [ "$#" -eq 1 ]; then
  export TAG_VERSION=$1
  export REGISTRY="appdynamics"
elif [ "$#" -eq 2 ]; then
  export TAG_VERSION=$1;
  export REGISTRY=$2;
else
  echo "Usage: tagAll.sh <tag> [<registry>]"
  exit
fi

export TOMCAT_LATEST=`docker images | grep 'appdynamics/adcapital-tomcat' | grep 'latest' | awk '{print $3}'`
export APPLICATIONPROCESSOR_LATEST=`docker images | grep 'appdynamics/adcapital-applicationprocessor' | grep 'latest' | awk '{print $3}'`
export QUEUEREADER_LATEST=`docker images | grep 'appdynamics/adcapital-queuereader' | grep 'latest' | awk '{print $3}'`

docker tag -f $TOMCAT_LATEST appdynamics/adcapital-tomcat:$TAG_VERSION
docker tag -f $APPLICATIONPROCESSOR_LATEST appdynamics/adcapital-applicationprocessor:$TAG_VERSION
docker tag -f $QUEUEREADER_LATEST appdynamics/adcapital-queuereader:$TAG_VERSION

if [ ${REGISTRY} == "appdynamics" ]; then
  echo "Tagging to Default Registry: Dockerhub"
  docker tag -f $TOMCAT_LATEST appdynamics/adcapital-tomcat:$TAG_VERSION
  docker tag -f $APPLICATIONPROCESSOR_LATEST appdynamics/adcapital-applicationprocessor:$TAG_VERSION
  docker tag -f $QUEUEREADER_LATEST appdynamics/adcapital-queuereader:$TAG_VERSION
else
  echo "Tagging to Registry: ${REGISTRY}"
  docker tag -f $TOMCAT_LATEST ${REGISTRY}/adcapital/adcapital-tomcat:$TAG_VERSION
  docker tag -f $APPLICATIONPROCESSOR_LATEST ${REGISTRY}/adcapital/adcapital-applicationprocessor:$TAG_VERSION
  docker tag -f $QUEUEREADER_LATEST ${REGISTRY}/adcapital/adcapital-queuereader:$TAG_VERSION
fi

if [[ `docker images -q --filter "dangling=true"` ]]
then
  echo
  echo "Deleting intermediate containers..."
  docker images -q --filter "dangling=true" | xargs docker rmi;
fi
