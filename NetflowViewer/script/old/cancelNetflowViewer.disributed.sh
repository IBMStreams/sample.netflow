#!/bin/bash

## Copyright (C) 2015  International Business Machines Corporation
## All Rights Reserved

################### parameters used in this script ##############################

#set -o xtrace
#set -o pipefail

namespace=application
composite=NetflowViewer

self=$( basename $0 .sh )
here=$( cd ${0%/*} ; pwd )
projectDirectory=$( cd $here/.. ; pwd )

logDirectory=$projectDirectory/log

domain=ViewerDomain
instance=ViewerInstance

################### functions used in this script #############################

die() { echo ; echo -e "\e[1;31m$*\e[0m" >&2 ; exit 1 ; }
step() { echo ; echo -e "\e[1;34m$*\e[0m" ; }

################################################################################

[ -d $logDirectory ] || mkdir -p $logDirectory || echo "sorry, could not create directory '$logDirectory', $?"

cd $projectDirectory || die "Sorry, could not change to $projectDirectory, $?"

step "getting logs for instance $instance ..."
streamtool getlog -i $instance -d $domain --includeapps --file $logDirectory/$composite.distributed.logs.tar.gz || die "sorry, could not get logs, $!"

step "cancelling distributed application '$namespace.$composite' ..."
jobs=$( streamtool lspes -i $instance -d $domain | grep $namespace::$composite | gawk '{ print $1 }' )
#streamtool canceljob -i $instance -d $domain --collectlogs ${jobs[*]} --trace trace || die "sorry, could not cancel application, $!"
streamtool canceljob -i $instance -d $domain --collectlogs ${jobs[*]} || die "sorry, could not cancel application, $!"

exit 0
