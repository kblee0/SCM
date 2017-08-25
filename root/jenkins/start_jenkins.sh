#!/bin/bash
JENKINS=/users/ktf/cscm/root/jenkins
JENKINS_HOME=${JENKINS}/home
JAVA=/opt/java7/bin/java

ADMIN_USER=admin


export JENKINS_HOME

if [ -f ${JENKINS}/log/jenkins.log ]
then
	mv -f ${JENKINS}/log/jenkins.log ${JENKINS}/log/jenkins.log.old
fi
#${JAVA} -jar ${JENKINS}/jenkins.war --httpPort=8080 --logfile=${JENKINS}/log/jenkins.log &
${JAVA} -jar ${JENKINS}/jenkins.war --httpPort=8080 --logfile=${JENKINS}/log/jenkins.log --argumentsRealm.passwd.admin=admin --argumentsRealm.roles.admin=admin &
#${JAVA} -jar ${JENKINS}/jenkins.war --httpPort=8080
#--logfile=${JENKINS}/log/jenkins.log

