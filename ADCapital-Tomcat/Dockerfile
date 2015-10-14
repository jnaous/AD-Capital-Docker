FROM appdynamics/adcapital-java:latest

# Install Gradle
RUN curl -O http://downloads.gradle.org/distributions/gradle-2.1-bin.zip
RUN unzip gradle-2.1-bin.zip -d /opt/
RUN rm gradle-2.1-bin.zip
ENV GRADLE_HOME /opt/gradle-2.1
ENV PATH $PATH:$GRADLE_HOME/bin

# Environment vars: Tomcat
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.0.14
ENV CATALINA_HOME /tomcat

# Install Tomcat
RUN curl -O -k https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz \
    && curl -O -k https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 \
    && md5sum apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 \
    && tar zxf apache-tomcat-*.tar.gz \
    && rm apache-tomcat-*.tar.gz* \
    && mv apache-tomcat-${TOMCAT_MINOR_VERSION} tomcat
RUN cd ${CATALINA_HOME}/bin;chmod +x *.sh

ADD AppServerAgent.zip /
RUN unzip -q /AppServerAgent.zip -d ${CATALINA_HOME}/appagent; rm AppServerAgent.zip

ENV ANALYTICS_AGENT_HOME /analytics-agent
ADD AnalyticsAgent.zip /
RUN unzip AnalyticsAgent.zip
RUN rm -f AnalyticsAgent.zip
ADD start-analytics.sh /usr/bin/start-analytics
RUN chmod 744 /usr/bin/start-analytics

# Add Log Analytics job files
ADD portal-log4j.job ${ANALYTICS_AGENT_HOME}/
ADD processor-log4j.job ${ANALYTICS_AGENT_HOME}/
ADD rest-log4j.job ${ANALYTICS_AGENT_HOME}/

RUN export TERM=${TERM:-dumb}

# Copy AD-Capital project from build dir
ADD AD-Capital /AD-Capital

# Gradle build
RUN cd /AD-Capital;gradle build;

ADD controller-info.xml /
ADD startup.sh /
ADD env.sh /
RUN chmod 744 /startup.sh

# Note: This command should not return or the container will exit
CMD "/startup.sh"

EXPOSE 80
EXPOSE 8080
EXPOSE 8009
