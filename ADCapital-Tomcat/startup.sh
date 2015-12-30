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
    cp /${ANALYTICS_AGENT_HOME}/rest-log4j.job ${ANALYTICS_AGENT_HOME}/conf/job/
    jobfile=${ANALYTICS_AGENT_HOME}/conf/job/rest-log4j.job
    configureLogAnalytics
    rm -f /${ANALYTICS_AGENT_HOME}/*.job

elif [ -n "${portal}" ]; then
    cp /AD-Capital/Portal/build/libs/portal.war /tomcat/webapps;
    cp /${ANALYTICS_AGENT_HOME}/portal-log4j.job ${ANALYTICS_AGENT_HOME}/conf/job/
    jobfile=${ANALYTICS_AGENT_HOME}/conf/job/portal-log4j.job
    configureLogAnalytics
    rm -f /${ANALYTICS_AGENT_HOME}/*.job

elif [ -n "${processor}" ]; then
    cp /AD-Capital/Processor/build/libs/processor.war /tomcat/webapps;
    cp /${ANALYTICS_AGENT_HOME}/processor-log4j.job ${ANALYTICS_AGENT_HOME}/conf/job/
    jobfile=${ANALYTICS_AGENT_HOME}/conf/job/processor-log4j.job
    configureLogAnalytics
    rm -f /${ANALYTICS_AGENT_HOME}/*.job
fi

CONTROLLER_INFO_SETTINGS="s/CONTROLLERHOST/${CONTROLLER}/g;
s/CONTROLLERPORT/${APPD_PORT}/g;
s/APP/${APP_NAME}/g;s/TIER/${TIER_NAME}/g;
s/NODE/${NODE_NAME}/g;
s/FOO/${SIM_HIERARCHY_1}/g;
s/BAR/${SIM_HIERARCHY_2}/g;
s/BAZ/${HOSTNAME}/g;
s/ACCOUNTNAME/${ACCOUNT_NAME%%_*}/g;
s/ACCOUNTACCESSKEY/${ACCESS_KEY}/g"
# Uncomment to configure App Server Agent using controller-info.xml
# sed -e "${CONTROLLER_INFO_SETTINGS}" /controller-info.xml > /${CATALINA_HOME}/appagent/conf/controller-info.xml

# Start standalone Analytics Agent
start-analytics

# Start App Server Agent
echo APP_AGENT_JAVA_OPTS: ${APP_AGENT_JAVA_OPTS};
echo JMX_OPTS: ${JMX_OPTS}
cd ${CATALINA_HOME}/bin;
java -javaagent:${CATALINA_HOME}/appagent/javaagent.jar ${APP_AGENT_JAVA_OPTS} ${JMX_OPTS} -cp ${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar org.apache.catalina.startup.Bootstrap > appserver-agent-startup.out 2>&1
