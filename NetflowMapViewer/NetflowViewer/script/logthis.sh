#!/bin/bash

## Copyright (C) 2011, 2015  International Business Machines Corporation
## All Rights Reserved

################### parameters used in this script ##############################

#set -o xtrace
set -o pipefail

here=$( cd ${0%/*} ; pwd )
projectDirectory=$( cd $here/.. ; pwd )

name=$( basename $1 .sh )

logDirectory=$projectDirectory/log
logFile=$logDirectory/$name.log

################################################################################

[ -d $logDirectory ] || mkdir -p $logDirectory || die "sorry, could not create directory '$logDirectory', $?"
[ -f $logFile ] && echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> $logFile

$@ 2>&1 | tee -a $logFile
exit $?
