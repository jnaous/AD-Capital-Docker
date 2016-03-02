#!/bin/sh
source /env.sh

configureLogAnalytics() {
    if [ "$(grep '_NODE_NAME' ${jobfile})" ]; then
        echo "${jobfile}: setting NODE_NAME to "${NODE_NAME}""
        sed -i "s/_NODE_NAME/${NODE_NAME}/g" ${jobfile}
    else
        echo "Error configuring ${jobfile}: _NODE_NAME not found"
    fi

    if [ "$(grep '_TIER_NAME' ${jobfile})" ]; then
        echo "${jobfile}: setting TIER_NAME to "${TIER_NAME}""
        sed -i "s/_TIER_NAME/${TIER_NAME}/g" ${jobfile}
    else
        echo "Error configuring ${jobfile}: _TIER_NAME not found"
    fi

    if [ "$(grep '_APP_NAME' ${jobfile})" ]; then
        echo "${jobfile}: setting APP_NAME to "${APP_NAME}""
        sed -i "s/_APP_NAME/${APP_NAME}/g" ${jobfile}
    else
        echo "Error configuring ${jobfile}: _APP_NAME not found"
    fi
}

if [ "${create_schema}" == "true" ]; then
	cd /AD-Capital; gradle createDB
fi

if [ -n "${rest}" ]; then
    cp  /AD-Capital/Rest/build/libs/Rest.war /tomcat/webapps;
    cp /${MACHINE_AGENT_HOME}/rest-log4j.job ${MACHINE_AGENT_HOME}/monitors/analytics-agent/conf/job/
    jobfile=${MACHINE_AGENT_HOME}/monitors/analytics-agent/conf/job/rest-log4j.job
    configureLogAnalytics
    rm -f /${MACHINE_AGENT_HOME}/*.job
    MACHINE_NAME=ADCapital-Rest

elif [ -n "${portal}" ]; then
    cp /AD-Capital/Portal/build/libs/portal.war /tomcat/webapps;
    cp /${MACHINE_AGENT_HOME}/portal-log4j.job ${MACHINE_AGENT_HOME}/monitors/analytics-agent/conf/job/
    jobfile=${MACHINE_AGENT_HOME}/monitors/analytics-agent/conf/job/portal-log4j.job
    configureLogAnalytics
    rm -f /${MACHINE_AGENT_HOME}/*.job
    MACHINE_NAME=ADCapital-Portal

elif [ -n "${processor}" ]; then
    cp /AD-Capital/Processor/build/libs/processor.war /tomcat/webapps;
    cp /${MACHINE_AGENT_HOME}/processor-log4j.job ${MACHINE_AGENT_HOME}/monitors/analytics-agent/conf/job/
    jobfile=${MACHINE_AGENT_HOME}/monitors/analytics-agent/conf/job/processor-log4j.job
    configureLogAnalytics
    rm -f /${MACHINE_AGENT_HOME}/*.job
    MACHINE_NAME=ADCapital-Processor
fi

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
java -javaagent:${CATALINA_HOME}/appagent/javaagent.jar ${APP_AGENT_JAVA_OPTS} ${JMX_OPTS} -cp ${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar org.apache.catalina.startup.Bootstrap > appserver-agent-startup.out 2>&1
