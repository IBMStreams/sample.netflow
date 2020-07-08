#!/bin/bash

## Copyright (C) 2015  International Business Machines Corporation
## All Rights Reserved

################### parameters used in this script ##############################

#set -o xtrace
#set -o pipefail

here=$( cd ${0%/*} ; pwd )
projectDirectory=$( cd $here/.. ; pwd )

geographyURL=http://geolite.maxmind.com/download/geoip/database
geographyDirectory=$projectDirectory/geo

geographyPackageFile=GeoLite2-City-CSV.zip
geographyLocationsFile=GeoLite2-City-Locations-en.csv
geographyIPv4File=GeoLite2-City-Blocks-IPv4.csv
geographyIPv6File=GeoLite2-City-Blocks-IPv6.csv

################### functions used in this script #############################

die() { echo ; echo -e "\e[1;31m$*\e[0m" >&2 ; exit 1 ; }
step() { echo ; echo -e "\e[1;34m$*\e[0m" ; }

################################################################################

step "getting geography data package $geographyPackageFile from $geographyURL ..."
[ -f $geographyDirectory/$geographyPackageFile ] && exit 0
curl -o $geographyDirectory/$geographyPackageFile --create-dirs $geographyURL/$geographyPackageFile || die "sorry, could not download geography data package $geographyPackageFile from $geographyURL" 

step "unpacking geography data package $geographyPackageFile ..."
unzip -j -d $geographyDirectory $geographyDirectory/$geographyPackageFile || die "sorry, could not unpack geography data package $geographyPackageFile" 
[ -f $geographyDirectory/$geographyLocationsFile ] || die "sorry, $geographyLocationsFile missing from geography data package $geographyPackageFile"
[ -f $geographyDirectory/$geographyIPv4File ] || die "sorry, $geographyIPv4File missing from geography data package $geographyPackageFile"
[ -f $geographyDirectory/$geographyIPv6File ] || die "sorry, $geographyIPv6File missing from geography data package $geographyPackageFile"

###step "correcting $geographyIPv4File ..."
###mv $geographyDirectory/$geographyIPv4File $geographyDirectory/$geographyIPv4File.original
###perl -ne 'if (substr($_,0,15) eq "131.176.0.0/16,") { print "131.176.0.0/16,3176589,,,0,0,,41.8250843,12.6684535\n" } else { print $_; }' <$geographyDirectory/$geographyIPv4File.original >$geographyDirectory/$geographyIPv4File

exit 0
