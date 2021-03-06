#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { open STDERR, '>', '/dev/null' };

use FindBin '$Bin';
use lib "$Bin/lib";
use Test::More tests => 2;
use Catalyst::Test 'Craiglickr';

use feature ':5.10';

is_deeply (
	Craiglickr->config->{Craiglickr}{location}
	, {
		'cross_posting' => '1',
		'max' => '3',
		'restrict' => '0',
		'default' => '0',
		'cross_metro' => '0'
	}
	, 'location'
);

is_deeply (
	Craiglickr->config->{Craiglickr}{board}
	, {
		'owner' => '1',
		'cross_posting' => '0',
		'restrict' => '0',
		'default' => '0',
		'max' => 1
	}
	, 'board'
);
