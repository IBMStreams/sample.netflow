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
workspaceDirectory=$( cd $here/../.. ; pwd )

networkToolkitDirectory=$HOME/git/streamsx.network/com.ibm.streamsx.network

netflowAggregatorDirectory=$workspaceDirectory/NetflowAggregator

inetToolkitDirectory=$HOME/git/streamsx.inet/com.ibm.streamsx.inet

buildDirectory=$projectDirectory/output/build/$composite.distributed

dataDirectory=$projectDirectory/data

coreCount=$( cat /proc/cpuinfo | grep processor | wc -l )

domain=ViewerDomain
instance=ViewerInstance

toolkitList=(
$netflowAggregatorDirectory
$networkToolkitDirectory
$inetToolkitDirectory
)

compilerOptionsList=(
--verbose-mode
--rebuild-toolkits
--spl-path=$( IFS=: ; echo "${toolkitList[*]}" )
--standalone-application
--optimized-code-generation
--cxx-flags=-g3
--static-link
--main-composite=$namespace::$composite
--output-directory=$buildDirectory 
--data-directory=data
--num-make-threads=$coreCount
)

compileTimeParameterList=(
)

submitParameterList=(
webPort=6060
socketPort=6061
relayPort=6062
)

tracing=info # ... one of ... off, error, warn, info, debug, trace

################### functions used in this script #############################

die() { echo ; echo -e "\e[1;31m$*\e[0m" >&2 ; exit 1 ; }
step() { echo ; echo -e "\e[1;34m$*\e[0m" ; }

################################################################################

cd $projectDirectory || die "Sorry, could not change to $projectDirectory, $?"

#[ ! -d $buildDirectory ] || rm -rf $buildDirectory || die "Sorry, could not delete old '$buildDirectory', $?"
[ -d $dataDirectory ] || mkdir -p $dataDirectory || die "Sorry, could not create '$dataDirectory, $?"

step "configuration for standalone application '$namespace.$composite' ..."
( IFS=$'\n' ; echo -e "\nStreams toolkits:\n${toolkitList[*]}" )
( IFS=$'\n' ; echo -e "\nStreams compiler options:\n${compilerOptionsList[*]}" )
( IFS=$'\n' ; echo -e "\n$composite compile-time parameters:\n${compileTimeParameterList[*]}" )
( IFS=$'\n' ; echo -e "\n$composite submission-time parameters:\n${submitParameterList[*]}" )
echo -e "\ndomain: $domain"
echo -e "\ninstance: $instance"
echo -e "\ntracing: $tracing"

step "building standalone application '$namespace.$composite' ..."
sc "${compilerOptionsList[@]}" -- "${compileTimeParameterList[@]}" || die "Sorry, could not build '$composite', $?" 

step "granting read permission for instance '$instance' log directory to user '$USER' ..."
sudo chmod o+r -R /tmp/Streams-$domain/logs/$HOSTNAME/instances

step "submitting distributed application '$namespace.$composite' ..."
bundle=$buildDirectory/$namespace.$composite.sab
parameters=$( printf ' --P %s' ${submitParameterList[*]} )
streamtool submitjob -i $instance -d $domain --config tracing=$tracing $parameters $bundle || die "sorry, could not submit application '$composite', $?"

exit 0
