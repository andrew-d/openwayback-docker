#!/bin/sh

# TODO: should set our user to not-root
# exec /sbin/setuser tomcat

exec ${CATALINA_HOME}/bin/catalina.sh run
