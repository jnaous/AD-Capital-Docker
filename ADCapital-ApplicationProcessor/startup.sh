#!/bin/sh
source /env.sh

MACHINE_NAME=ADCapital-ApplicationProcessor

# Configure App Server Agent using controller-info.xml
sed -i "s/<controller-host>/<controller-host>${CONTROLLER}/g" /${CATALINA_HOME}/appagent/conf/controller-info.xml
sed -i "s/<controller-port>/<controller-port>${APPD_PORT}/g" /${CATALINA_HOME}/appagent/conf/controller-info.xml
sed -i "s/<account-access-key>/<account-access-key>${ACCESS_KEY}/g" /${CATALINA_HOME}/appagent/conf/controller-info.xml
sed -i "s/<application-name>/<application-name>${APP_NAME}/g" /${CATALINA_HOME}/appagent/conf/controller-info.xml
sed -i "s/<tier-name>/<tier-name>${TIER_NAME}/g" /${CATALINA_HOME}/appagent/conf/controller-info.xml
sed -i "s/<node-name>/<node-name>${NODE_NAME}/g" /${CATALINA_HOME}/appagent/conf/controller-info.xml
# Uncomment for multi-tenant controllers
# sed -i "s/<account-name>/<account-name>${ACCOUNT_NAME%%_*}/g" /${CATALINA_HOME}/appagent/conf/controller-info.xml

# Configure Machine Agent using controller-info.xml
sed -i "s/<controller-host>/<controller-host>${CONTROLLER}/g" /${MACHINE_AGENT_HOME}/conf/controller-info.xml
sed -i "s/<controller-port>/<controller-port>${APPD_PORT}/g" /${MACHINE_AGENT_HOME}/conf/controller-info.xml
sed -i "s/<account-access-key>/<account-access-key>${ACCESS_KEY}/g" /${MACHINE_AGENT_HOME}/conf/controller-info.xml
sed -i "s/<application-name>/<application-name>${APP_NAME}/g" /${MACHINE_AGENT_HOME}/conf/controller-info.xml
sed -i "s/<tier-name>/<tier-name>${TIER_NAME}/g" /${MACHINE_AGENT_HOME}/conf/controller-info.xml
sed -i "s/<node-name>/<node-name>${NODE_NAME}/g" /${MACHINE_AGENT_HOME}/conf/controller-info.xml
sed -i "s/<machine-path>/<machine-path>${MACHINE_PATH_1}|${MACHINE_PATH_2}|${MACHINE_NAME}/g" ${MACHINE_AGENT_HOME}/conf/controller-info.xml
# Uncomment for multi-tenant controllers
# sed -i "s/<account-name>/<account-name>${ACCOUNT_NAME%%_*}/g" /${MACHINE_AGENT_HOME}/conf/controller-info.xml

# Enable Analytics
start-analytics

# Start Machine Agent
echo MACHINE_AGENT_JAVA_OPTS: ${MACHINE_AGENT_JAVA_OPTS}
echo JMX_OPTS: ${JMX_OPTS}
java ${MACHINE_AGENT_JAVA_OPTS} -jar ${MACHINE_AGENT_HOME}/machineagent.jar > ${MACHINE_AGENT_HOME}/machine-agent.out 2>&1 &

# Start App Server Agent
echo APP_AGENT_JAVA_OPTS: ${APP_AGENT_JAVA_OPTS};
echo JMX_OPTS: ${JMX_OPTS}
cd ${CATALINA_HOME}/bin;
java -javaagent:${CATALINA_HOME}/appagent/javaagent.jar ${APP_AGENT_JAVA_OPTS} ${JMX_OPTS} -jar ${CLIENT_HOME}/Verification.jar
