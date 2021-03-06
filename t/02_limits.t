#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { open STDERR, '>', '/dev/null' };

use FindBin '$Bin';
use lib "$Bin/lib";
use Test::More tests => 5;
use Catalyst::Test 'Craiglickr';

use feature ':5.10';
	
subtest 'Defaults' => sub {
	plan tests => 4;
	
	like ( request('/craiglickr/locations/hou,hou/boards/ctd')->content, qr/same location twice/i, 'exact location dupe' );
	like ( request('/craiglickr/locations//boards/ctd')->content, qr/no locations/i, 'no locations' );
	like ( request('/craiglickr/locations/hou,bhm,dhn,aub,csg/boards/ctd')->content, qr/only post to 3 locations/i, 'max locations' );
	like ( request('/craiglickr/locations/phx-evl,phx-cph/boards')->content, qr/same location twice/i, 'two metro-areas in same city' );
};

#Craiglickr->config->{Craiglickr}{location} = {cross_posting => 1, cross_metro => 0, max => 4};
#Craiglickr->config->{Craiglickr}{category} = {cross_posting => 0, owner => 1};

{
	local Craiglickr->config->{Craiglickr}{location}{cross_posting} = 0;
	like ( request('/craiglickr/locations/hou,bhm/boards/ctd')->content, qr/Cross-posting.*?disabled/i, 'x-posting disabled (location)' );
}
{
	local Craiglickr->config->{Craiglickr}{board}{cross_posting} = 0;
	like ( request('/craiglickr/locations/hou/boards/ctd,cto')->content, qr/Cross-posting.*?disabled/i, 'x-posting disabled (boards)' );
	local Craiglickr->config->{Craiglickr}{board}{cross_posting} = 1;
	like ( request('/craiglickr/locations/hou/boards/ctd,ctd')->content, qr/same board twice/i, 'two of the same boards' );
}

subtest 'No restrictions' => sub {
	plan tests => 4;
	local Craiglickr->config->{Craiglickr}{location} = {cross_posting => 1, cross_metro => 1, max => 100};
	local Craiglickr->config->{Craiglickr}{board} = {cross_posting => 1, owner => 1, max => 100};
	ok ( request('/craiglickr/locations/phx-evl,phx-cph/boards')->is_success, 'two metro-areas in same city' );
	ok ( request('/craiglickr/locations/hou/boards/ctd,cto')->is_success, 'two different boards for one posting' );
	ok ( request('/craiglickr/locations/hou,phx-evl/boards/ctd,cto')->is_success, 'two different boards for two different cities' );
	ok ( request('/craiglickr/locations/phx-evl,phx-cph/boards/ctd,cto')->is_success, 'two different categories for two different metro-areas in the same city' );
};
