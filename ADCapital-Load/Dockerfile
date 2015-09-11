FROM appdynamics/adcapital-java:latest

# Gradle
RUN curl -O http://downloads.gradle.org/distributions/gradle-2.1-bin.zip
RUN unzip gradle-2.1-bin.zip -d /opt/
RUN rm gradle-2.1-bin.zip
ENV GRADLE_HOME /opt/gradle-2.1
ENV PATH $PATH:$GRADLE_HOME/bin

# Add AD-Capital-Load project from build dir
ADD AD-Capital-Load /AD-Capital-Load
ENV LOAD_GEN_HOME /AD-Capital-Load
RUN cd /AD-Capital-Load; gradle distZip
RUN unzip AD-Capital-Load/build/distributions/load-generator.zip -d /
RUN chmod +x $LOAD_GEN_HOME/bin/*
ADD env.sh /
ADD startup.sh /
CMD ["/bin/bash","/startup.sh"]
