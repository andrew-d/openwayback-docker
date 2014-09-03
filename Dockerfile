FROM phusion/baseimage:0.9.13
MAINTAINER Andrew Dunham <andrew@du.nham.ca>

# Remove the SSH daemon from baseimage-docker
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Setup baseimage-docker
ENV HOME /root
CMD ["/sbin/my_init"]

# Install basics
RUN apt-get -qq update && \
    apt-get install -y --force-yes --no-install-recommends ca-certificates curl unzip && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*

# Install Oracle Java 7
ENV JAVA_VER 7
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle
RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    echo 'deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 && \
    apt-get update && \
    echo oracle-java${JAVA_VER}-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && \
    apt-get install -y --force-yes --no-install-recommends oracle-java${JAVA_VER}-installer oracle-java${JAVA_VER}-set-default && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/oracle-jdk${JAVA_VER}-installer

# Install Tomcat
ENV TOMCAT_MAJOR_VERSION 6
ENV TOMCAT_MINOR_VERSION 6.0.41
ENV CATALINA_HOME /tomcat
RUN cd / && \
    curl -# -O https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
    curl -# https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat

# Remove all old webapps
RUN rm -rf ${CATALINA_HOME}/webapps/*

# Configuration for OpenWayback
ENV OPENWAYBACK_VERSION 2.0.0.BETA.2

# Download and install OpenWayback
RUN curl -# -O http://search.maven.org/remotecontent?filepath=org/netpreserve/openwayback/openwayback-dist/${OPENWAYBACK_VERSION}/openwayback-dist-${OPENWAYBACK_VERSION}-${OPENWAYBACK_VERSION}.tar.gz && \
    tar zxf openwayback-dist*.tar.gz && \
    mkdir ${CATALINA_HOME}/webapps/ROOT && \
    unzip -qq openwayback/openwayback*.war -d ${CATALINA_HOME}/webapps/ROOT/ && \
    rm -r openwayback*

# Add config files
ADD files/wayback.xml ${CATALINA_HOME}/webapps/ROOT/WEB-INF/wayback.xml
ADD files/BDBCollection.xml ${CATALINA_HOME}/webapps/ROOT/WEB-INF/BDBCollection.xml

# Add service file
RUN mkdir -p /etc/service/tomcat
ADD files/tomcat_run.sh /etc/service/tomcat/run
RUN chmod +x /etc/service/tomcat/run

# Expose the Tomcat port
EXPOSE 8080
