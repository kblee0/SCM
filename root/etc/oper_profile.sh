#!/bin/ksh

# Default terminal
stty susp ''
stty intr ''
stty erase ''
stty kill ''
stty eof ''

umask 022


# Korean languae
stty cs8 -parenb -istrip -ixany

export LANG=ko_KR.eucKR

# Prompt
export HOSTNAME=`hostname`
export LOGNAME=`logname`
export PS1='[${LOGNAME}@${HOSTNAME}:${PWD}]# '


# Altibase
export ALTIBASE_HOME=/altibase/altibase_home

export PATH=${PATH}:${ALTIBASE_HOME}/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ALTIBASE_HOME}/lib

# Oracle
export ORACLE_BASE=/oracle/app/oracle
export ORACLE_HOME=/oracle/app/oracle/product
#export ORACLE_HOME=/oracle/app/oracle/product/10.2.0
export ORACLE_SID=DEVCRAB
export TWO_TASK=DEVCRAB

export PATH=${PATH}:${ORACLE_HOME}/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ORACLE_HOME}/lib:${ORACLE_HOME}/rdbms/lib

# Java
export JAVA_HOME=/opt/java1.5
export PATH=${PATH}:${JAVA_HOME}/bin


