#!/bin/ksh
export HOSTNAME=`hostname`
export LOGNAME=`id -un`
export PS1='[${LOGNAME}@${HOSTNAME}:${PWD}]# '
