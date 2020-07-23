#!/bin/bash
#set -o xtrace
#set -o pipefail






################### parameters used in this script ##############################

self=${0##*/}
here=$( cd ${0%/*} ; pwd )
workspace=$( cd $here/../.. ; pwd )
project=$workspace/NetflowViewer

date=$( date +%Y-%m-%d )
package=$HOME/streams4.NetflowViewer_$date.tar.gz

################### functions used in this script #############################

die() { echo ; echo -e "\e[1;31m$*\e[0m" >&2 ; exit 1 ; }
step() { echo ; echo -e "\e[1;34m$*\e[0m" ; }

################################################################################

[ -f $package ] && rm $package

cd $workspace || die "sorry, could not change to directory '$workspace', $?"

chmod +r -R NetflowViewer || die "sorry, could not set read permission in project 'NetflowViewer', $?"

step "creating package $package ..."
tar -cvzf $package \
--exclude='*~' \
--exclude='#*#' \
--exclude='output' \
--exclude='.git' \
--exclude='geo' \
--exclude='download' \
--exclude='.svn' \
--exclude='StreamsLogsJob*.tgz' \
--exclude='.metadata' \
--exclude='.tempLaunch' \
--exclude='*.splbuild' \
--exclude='*_cpp.pm' \
--exclude='*_h.pm' \
--exclude='debug.*' \
--exclude='log' \
--exclude='.DS_Store' \
NetflowViewer \
|| die "Sorry, could not create package $package, $?"
step "created package $package"

exit 0
