# AD-Capital-Docker

Building the Container Images
-----------------------------

To build the containers, you need to supply paths to the AppDynamics agent installers used by the demo containers.  
Download the latest versions directly from the [AppDynamics download site](https://download.appdynamics.com)

1. Run `build.sh` without commandline args to be prompted (with autocomplete) for the agent installer paths __or__
2. Run `build.sh -a <App Server Agent zip> -m <Machine Agent zip> [-j <Oracle JDK7>]` to supply agent installer paths

Note: Run build.sh with the `-p` flag to prepare the build environment but skip the actual docker container builds.  This will build the Dockerfiles and add the AppDynamics agents to the build dirs: the containers can then be built manually with `docker build -t <container-name> .`  Using this option saves time when making updates to only one or two containers.  You can also use the `-j` flag to avoid downloading the Oracle JDK.

### Optimizing network download time

If you want to (re-)build the containers with different agents and want to skip git clones, gradle download/builds or JDK/Tomcat downloads, you can use the following optional flags to build using local copies of all these artifacts:

- `-j <location of the Oracle JDK rpm distro>`
- `-t <location of the Apache Tomcat tar.gz distro>`
- `-b <path to the AD-Capital project>`
- `-l <path to the AD-Capital-Load project>`

When using these flags, make sure that the paths are correct on your build system and that the downloaded artifacts are in the correct format.  You will need to run `gradle build` on the AD-Capital and AD-Capital-Load projects manually to generate the correct libraries.


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
