#!/bin/ksh
export ORACLE_BASE=/oracle/app/oracle
export ORACLE_HOME=/oracle/app/oracle/product
export ORACLE_SID=DEVCRAB
export TWO_TASK=DEVCRAB
export NLS_LANG=American_America.KO16KSC5601

export PATH=${PATH}:${ORACLE_HOME}/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ORACLE_HOME}/lib:${ORACLE_HOME}/rdbms/lib
