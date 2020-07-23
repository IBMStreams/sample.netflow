#!/bin/bash

## Copyright (C) 2015  International Business Machines Corporation
## All Rights Reserved

################### parameters used in this script ##############################

#set -o xtrace
#set -o pipefail

here=$( cd ${0%/*} ; pwd )
projectDirectory=$( cd $here/.. ; pwd )

maxmindDirectory=$projectDirectory/geo/www.maxmind.com

ibmDirectory=$projectDirectory/geo/w3.ibm.com

geoDirectory=$projectDirectory/geo

cat $maxmindDirectory/GeoLite2-City-Locations-en.csv > $geoDirectory/GeoLite2-City-Locations-en.csv || die "sorry, could not concatenate location data, $!"
tail -n +2 $ibmDirectory/IBMinternal-City-Locations-en.csv >> $geoDirectory/GeoLite2-City-Locations-en.csv || die "sorry, could not concatenate location data, $!"

grep -v "^9\." $maxmindDirectory/GeoLite2-City-Blocks-IPv4.csv > $geoDirectory/GeoLite2-City-Blocks-IPv4.csv  || die "sorry, could not concatenate IPv4 subnet data, $!"
grep "^9\." $ibmDirectory/IBMinternal-City-Blocks-IPv4.csv >> $geoDirectory/GeoLite2-City-Blocks-IPv4.csv  || die "sorry, could not concatenate IPv4 subnet data, $!"

cat $maxmindDirectory/GeoLite2-City-Blocks-IPv6.csv > $geoDirectory/GeoLite2-City-Blocks-IPv6.csv  || die "sorry, could not concatenate IPv6 subnet data, $!"

exit 0
