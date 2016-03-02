# AD-Capital-Docker

Building the Container Images
-----------------------------

To build the containers, you need to supply paths to the AppDynamics agent installers used by the demo containers.  
Download the latest versions directly from the [AppDynamics download site](https://download.appdynamics.com)

1. Run `build.sh` without commandline args to be prompted (with autocomplete) for the agent installer paths __or__
2. Run `build.sh -a <App Server Agent zip> -m <Machine Agent zip> [-j <Oracle JDK7>]` to supply agent installer paths

Note: Run build.sh with the `-p` flag to prepare the build environment but skip the actual docker container builds.  This will build the Dockerfiles and add the AppDynamics agents to the build dirs: the containers can then be built manually with `docker build -t <container-name> .`  Using this option saves time when making updates to only one or two containers.  You can also use the `-j` flag to avoid downloading the Oracle JDK.

Running the AD-Capital Demo
---------------------------

Run ./run.sh to start all the applications containers.
Note: The run.sh script will expect app name (default = AD-Capital), docker container version (default = latest) , controller host/port, account name and access key configuration. These should be set and exported in your shell before running the script. The script expects the following env vars to be set:

- `CONTR_HOST`
- `CONTR_PORT`
- `ACCOUNT_NAME`
- `ACCESS_KEY`
- `EVENT_ENDPOINT`

Tagging and Pushing to DockerHub
--------------------------------
Use the following utilities to manage container tags and push to DockerHhub

- `./tagAll.sh <tag>`
- `./pushAll.sh <tag>`
