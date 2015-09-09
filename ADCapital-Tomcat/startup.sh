#!/bin/sh

source /env.sh

cd /AD-Capital; gradle createDB

if [ -n "${rest}" ]; then
        cp  /AD-Capital/Rest/build/libs/Rest.war /tomcat/webapps;
fi

if [ -n "${portal}" ]; then
 	cp /AD-Capital/Portal/build/libs/portal.war /tomcat/webapps;
fi

echo APP_AGENT_JAVA_OPTS: ${APP_AGENT_JAVA_OPTS};
echo JMX_OPTS: ${JMX_OPTS}
cd ${CATALINA_HOME}/bin;

java -javaagent:${CATALINA_HOME}/appagent/javaagent.jar ${APP_AGENT_JAVA_OPTS} ${JMX_OPTS} -cp ${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar org.apache.catalina.startup.Bootstrap > appserver-agent-startup.out 2>&1
