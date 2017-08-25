#!/bin/ksh
export PATH=${SCM_ROOT}/bin:${SCM_ROOT}/opt/bin:${PATH}
export MANPATH=${MANPATH}:${SCM_ROOT}/opt/man:${SCM_ROOT}/opt/share/man

export SCM_HOME=${SCM_HOME:-${HOME}}
export SCM_USER=`whoami`
export SCM_OS=`uname -s`
export SMC_OS_RELEASE=`uname -r`

if [ "$SCM_MHOME" = "$SCM_HOME" ]
then
	SCM_MASTER=Y
fi

if [ "$SCM_BHOME" = "$SCM_HOME" ]
then
	SCM_MASTER=Y
fi

if [ x"$SCM_MASTER" = x"Y" ]
then
	export SCM_REPO_URL=${SCM_REPO_MURL}
fi

export EDITOR=vi

# 공지사항
announce

if [ -f ${SCM_HOME}/deploy/.profile ]
then
# Auto Update
	echo Checking upgrade..
	scm_update
	. ${SCM_HOME}/deploy/.profile
fi

function set_deploy {
	set_deploy.pl $*
	if [ $? -eq 0 ]
	then
		. ${SCM_HOME}/deploy/.profile
	fi
}

#alias cls='ls `echo $PWD | sed s"|${SCM_HOME}|${SCM_MHOME}|"`'
alias cdd='cd ${SCM_HOME}/deploy/${SCM_DEPLOY}'
alias cdlib='cd ${SCM_HOME}/deploy/${SCM_DEPLOY}/lib'
alias cdcfg='cd ${SCM_HOME}/deploy/${SCM_DEPLOY}/cfg'
alias cdbin='cd ${SCM_HOME}/deploy/${SCM_DEPLOY}/bin'

function cls {
	__O=$PWD
	__D=`echo $PWD | sed s"|${SCM_HOME}|${SCM_MHOME}|"`
	echo
	echo $__D
	echo
	cd $__D
	ls ${*:-}
	cd $__O
}


function cdc {
	__D=`echo $PWD | sed s"|${SCM_HOME}|${SCM_MHOME}|"`
	if [ x"$__D" = x"$PWD" ]
	then
		__D=`echo $PWD | sed s"|${SCM_MHOME}|${SCM_HOME}|"`
	fi
	cd $__D
}

function cdp {
	cd `scm_find_path cdp ${*:-}`
}

function cdh {
	cd ${SCM_HOME}/$1
}

function cds {
	cd `scm_find_path cds ${*:-}`
}

function cdi {
	cd `scm_find_path cdi ${*:-}`
}

function cdout {
	cd `scm_find_path cdout ${*:-}`
}

function chhome {
	if [ x"$1" = x ]
	then
		echo "chhome: change scm home directory"
		echo "Usage : chhome <directory>"
	elif [ -d "$1" ]
	then
		cd "$1"
		export SCM_HOME="${PWD}"
		export SCM_USER=`basename ${PWD}`

		echo "user working home directory is ${PWD}"
		if [ -f ${SCM_HOME}/deploy/.profile ]
		then
# Auto Update
			echo Checking upgrade..
			scm_update
			. ${SCM_HOME}/deploy/.profile
		fi  
	else
		echo $1 is not directory
	fi
}

