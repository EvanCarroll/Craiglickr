#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { open STDERR, '>', '/dev/null' };

use FindBin '$Bin';
use lib "$Bin/lib";
use Test::More tests => 6;
use Catalyst::Test 'Craiglickr';
	
use feature ':5.10';
 
is_deeply (
	Craiglickr->config->{Craiglickr}{location}
	, {
		'cross_posting' => '1',
		'max' => '3',
		'cross_metro' => '0'
	}
	, 'location'
);

is_deeply (
	Craiglickr->config->{Craiglickr}{category}
	, {
		'owner' => '1',
		'cross_posting' => '0'
	}
	, 'category'
);
