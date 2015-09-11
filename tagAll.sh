#! /bin/bash

if [ -z "$1" ]; then
  read -e -p "Version: " TAG_VERSION;
else
        export TAG_VERSION=$1;
fi

export TOMCAT_LATEST=`docker images | grep 'appdynamics/adcapital-tomcat' | grep 'latest' | awk '{print $3}'`
export APPLICATIONPROCESSOR_LATEST=`docker images | grep 'appdynamics/adcapital-applicationprocessor' | grep 'latest' | awk '{print $3}'`
export QUEUEREADER_LATEST=`docker images | grep 'appdynamics/adcapital-queuereader' | grep 'latest' | awk '{print $3}'`

docker tag -f $TOMCAT_LATEST appdynamics/adcapital-tomcat:$TAG_VERSION
docker tag -f $APPLICATIONPROCESSOR_LATEST appdynamics/adcapital-applicationprocessor:$TAG_VERSION
docker tag -f $QUEUEREADER_LATEST appdynamics/adcapital-queuereader:$TAG_VERSION

if [[ `docker images -q --filter "dangling=true"` ]]
then
  echo
  echo "Deleting intermediate containers..."
  docker images -q --filter "dangling=true" | xargs docker rmi;
fi
