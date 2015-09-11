# AD-Capital-Docker

Building the Container Images
-----------------------------

To build the containers, you need to supply paths to the AppDynamics agent installers used by the AD-Capital demo containers.

Run ./build.sh which would prompt for the agent installer paths
It requires AppServerAgent, AnalyticsAgent and Oracle JDk path(optional).

Running the AD-Capital Demo
---------------------------

Run ./run.sh by filling all the controller variables.
Note: The run.sh script will expect App name, version, controller host/port, account name and access key configuration.

CONTR_HOST
CONTR_PORT
ACCOUNT_NAME
ACCESS_KEY
EVENT_ENDPOINT

Tagging and Pushing to DockerHub
--------------------------------
Use the following utilities to manage container tags and push to DockerHhub

- `./tagAll.sh <tag>`
- `./pushAll.sh <tag>`
