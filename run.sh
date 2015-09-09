# Docker container version
if [ -z "$1" ]; then
        export VERSION="latest";
else
        export VERSION=$1;
fi
echo "Using version: $VERSION"

# Default application name
if [ -z "$2" ]; then
        export APP_NAME="AD-Capital";
else
        export APP_NAME=$2;
fi
echo "Application Name: $APP_NAME"

source env.sh

echo -n "adcapitaldb: "; docker run --name adcapitaldb -e MYSQL_ROOT_PASSWORD=singcontroller -p 3306:3306 -d mysql
echo -n "rabbitmq: "; docker run -d --hostname ec2-54-242-38-169.compute-1.amazonaws.com --name rabbitmq -e RABBITMQ_DEFAULT_USER=guest -e RABBITMQ_DEFAULT_PASS=guest -p 8080:15672 rabbitmq:3-management

echo -n "rest: "; docker run --name rest -h ${APP_NAME}-rest -e JVM_ROUTE=route1 -e rest=true -p 8081:8080\
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=${APP_NAME}_WEB1_NODE -e APP_NAME=$APP_NAME -e TIER_NAME=Authentication-Service \
	-e SIM_HIERARCHY_1=${SIM_HIERARCHY_1} -e SIM_HIERARCHY_2=${SIM_HIERARCHY_2} \
	--link adcapitaldb:adcapitaldb -d appdynamics/adcapital-tomcat:$VERSION
sleep 30

echo -n "portal: "; docker run --name portal -h ${APP_NAME}-portal -e JVM_ROUTE=route1 -e portal=true -p 8082:8080\
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=${APP_NAME}_WEB1_NODE -e APP_NAME=$APP_NAME -e TIER_NAME=Portal-Services \
	-e SIM_HIERARCHY_1=${SIM_HIERARCHY_1} -e SIM_HIERARCHY_2=${SIM_HIERARCHY_2} \
	--link rest:rest --link rabbitmq:rabbitmq -d appdynamics/adcapital-tomcat:$VERSION
sleep 30

echo -n "verification: "; docker run --name verification -h ${APP_NAME}-verification -e JVM_ROUTE=route1 -p 8083:8080\
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=${APP_NAME}_WEB1_NODE -e APP_NAME=$APP_NAME -e TIER_NAME=ApplicationProcessor \
	-e SIM_HIERARCHY_1=${SIM_HIERARCHY_1} -e SIM_HIERARCHY_2=${SIM_HIERARCHY_2} \
	--link adcapitaldb:adcapitaldb --link rabbitmq:rabbitmq -d appdynamics/adcapital-applicationprocessor:$VERSION
sleep 30
