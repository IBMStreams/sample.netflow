#!/usr/bin/perl

use English;
use File::Basename;
use File::Path qw(make_path remove_tree);
use Cwd 'abs_path';
#require LWP::UserAgent;
use LWP::Simple;
use URI;

my $self = basename($0 , ".pl");
my $here = abs_path dirname $0;

my $projectDirectory = abs_path "$here/..";

my $ibmDirectory = "$projectDirectory/geo/w3.ibm.com";
my $ibmExcelFile = "$ibmDirectory/report_IGA_Global_Q1_2016.xlsx";
my $spreadsheetDirectory = "$ibmDirectory/spreadsheets";

my $xlsx2csv = $ENV{HOME} . "/xlsx2csv-2016-01-09/xlsx2csv.py";

my %ambiguousCities = (
    "Rochester" => "MN",
    "Washington" => "DC",
    "Palisades" => "NY",
    );

sub tryCoordinates($) {

    my ($address) = @_;

    my $uri = URI->new('http://nominatim.openstreetmap.org/search');
    $uri->query_form( q=>"$address", format=>"xml", addressdetails=>"1" );
    my $geodata = get("$uri");    
    die "sorry, 'GET $uri' failed, $!\n" unless $geodata;

    my ($state) = $geodata =~ m/<state>(.+?)<\/state>/;
    my ($latitude) = $geodata =~ m/lat='([\-\d\.]+)'/;
    my ($longitude) = $geodata =~ m/lon='([\-\d\.]+)'/;
    $state = "" if $state =~ m/[^[:ascii:]]/;
    #print "sorry, 'GET $uri' has no coordinates, geodata=$geodata\n" unless $latitude && $longitude;

    return ( state=>$state, latitude=>$latitude, longitude=>$longitude );
}



sub getCoordinates($$$) {

    my ($country, $city, $street) = @_;

    $city .= ", $ambiguousCities{$city}" if exists $ambiguousCities{$city};

    my %geodata = tryCoordinates("$street, $city, $country");
    return %geodata if $geodata{latitude} && $geodata{longitude};

    my %geodata = tryCoordinates("$city, $country");
    return %geodata if $geodata{latitude} && $geodata{longitude};

    my %geodata = tryCoordinates("$country");
    return %geodata if $geodata{latitude} && $geodata{longitude};
    
    die "sorry, no geodata found for $country, $city, $street\n";
}


sub readIBMSpreadsheet($) {

    my ($filename) = @_;
    print "reading $filename ...\n";
    open(INPUT, "<", $filename) or die "sorry, could not read $filename, $!";
    while(<INPUT>) {
        next if substr($_,0,1) eq "#";
        chomp;

        my ($country, $city, $street) = m/^[^\t]*\t([^\t]*)\t([^\t]*)\t([^\t]*)\t/;
        next unless $country || $city || $street;

        my ($subnet, $subnetMasksize, $container, $containerMasksize) = m/\t(\d+\.\d+\.\d+\.\d+)\/(\d+)\t/ga; 
        next unless $subnet && $subnetMasksize;

        my $locationKey = "$country,$city";
        if (!exists $locations{$locationKey}) { 
            my $locationID = "IBM_" . scalar(keys %locations);
            my %geodata = getCoordinates($country, $city, $street);
            $locations{$locationKey} = { locationID=>$locationID, country=>$country, state=>$geodata{state}, city=>$city, latitude=>$geodata{latitude}, longitude=>$geodata{longitude} } ;
            print "$locationID: $street, $city, $country in state of '$geodata{state}' at coordinates $geodata{latitude}, $geodata{longitude}\n";
        }

        if (!exists $subnets{$subnet}) {
            $subnets{$subnet} = { masksize=>$subnetMasksize, locationKey=>$locationKey };
        } else {
            print "whoa, subnet $subnet found twice with different locations: $locationKey and $subnets{$subnet}{locationKey}\n" if $locationKey ne $subnets{$subnet}{locationKey};
            print "whoa, subnet $subnet found twice with different mask sizes: $subnetMasksize and $subnets{$subnet}{masksize}\n"  if $subnetMasksize < $subnets{$subnet}{masksize};
            $subnets{$subnet}{masksize} = $subnetMasksize if $subnetMasksize < $subnets{$subnet}{masksize};
        }
    }

    print "    found " . scalar(keys %locations) . " locations\n";
    print "    found " . scalar(keys %subnets) . " subnets\n";
}


sub writeLocationsFile($) {

    my ($filename) = @_;
    print "writing $filename ...\n";

    open(OUTPUT, ">", $filename) or die "sorry, could not write $filename, $!";
    print OUTPUT "geoname_id,locale_code,continent_code,continent_name,country_iso_code,country_name,subdivision_1_iso_code,subdivision_1_name,subdivision_2_iso_code,subdivision_2_name,city_name,metro_code,time_zone\n";
    foreach my $locationKey (keys %locations) {
        my %location = %{ $locations{$locationKey} };
        print OUTPUT "$location{locationID},,,,,$location{country},,$location{state},,,IBM $location{city},,\n" if $location{latitude} && $location{longitude};
    }
    close OUTPUT;
}


sub writeBlocksFile($) {

    my ($filename) = @_;
    print "writing $filename ...\n";

    open(OUTPUT, ">", $filename) or die "sorry, could not write $filename, $!";
    print OUTPUT "network,geoname_id,registered_country_geoname_id,represented_country_geoname_id,is_anonymous_proxy,is_satellite_provider,postal_code,latitude,longitude\n";
    foreach my $subnet (keys %subnets) {
        my $masksize = $subnets{$subnet}{masksize};
        my %location = %{ $locations{$subnets{$subnet}{locationKey}} };
        print OUTPUT "$subnet/$masksize,$location{locationID},,,,,,$location{latitude},$location{longitude}\n" if $location{latitude} && $location{longitude};
    }
    close OUTPUT;
}



%locations = ();
%subnets = ();

remove_tree $spreadsheetDirectory;

print "extracting spreadsheets from $ibmExcelFile ...\n";
system("$xlsx2csv --delimiter tab --all $ibmExcelFile $spreadsheetDirectory")==0 or die "sorry, could not execute 'xlsx2csv', $!";

foreach (glob "$spreadsheetDirectory/*") { readIBMSpreadsheet $_; }

writeLocationsFile("$ibmDirectory/IBMinternal-City-Locations-en.csv");
writeBlocksFile("$ibmDirectory/IBMinternal-City-Blocks-IPv4.csv");

exit 0;



