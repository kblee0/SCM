#!/bin/ksh
# deploy_build <deploy> REFRESH CLEAN BUILD CONFIRM
DEPLOY=crab100
#BUILD_PARAM="${DEPLOY} Y Y Y Y"
BUILD_PARAM="${DEPLOY} Y Y Y Y"
PRE_COMMAND=
POST_COMMAND=
#POST_COMMAND="scm_release ${DEPLOY}"
#POST_COMMAND="scm_patch_release ${DEPLOY}"
#MAKE_ARGS=
MAKE_ARGS="-j 20"

export PRE_COMMAND POST_COMMAND MAKE_ARGS

deploy_build ${BUILD_PARAM}
