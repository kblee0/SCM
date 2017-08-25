#!/bin/ksh
export SCM_MUSER=cscm
export SCM_BASE=/users/ktf/cscm
export SCM_ROOT=${SCM_BASE}/root
export SCM_MHOME=${SCM_MHOME:-${SCM_BASE}}
export SCM_BHOME=${SCM_BHOME:-${SCM_BASE}/build}

# SCM repository server config
export SCM_SERVER_HOST=crabrt
export SCM_SERVER_REPO_PATH=/users/ktf/cscm/repos
export SCM_SERVER_PORT=3690
export SCM_PWSERVER_PORT=3691
