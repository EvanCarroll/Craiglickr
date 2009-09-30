#!/usr/bin/env perl

## 
## THIS IS A QUICK TEST THAT GOES RIGHT TO A CITY
## THAT HAS SUBCRAIGSLIST SECTORS
## 

use strict;
use warnings;

use lib 'lib';
use Craiglickr::SiteListing;

my $db = {};

my $tor = Craiglickr::CommunitySite->new({
	name          => 'toronto'
	, posting_uid => 'tor'
	, uri_orig    => URI->new('http://toronto.craigslist.ca')
	, uri_dest    => URI->new('http://toronto.en.craigslist.ca/')
});

hash_write( $db, $tor );

sub hash_write {
	my ( $hash_ptr, $cs ) = @_;

	$hash_ptr->{$cs->name} = {
		name       => $cs->name
		, uri_orig => $cs->uri_orig->as_string
		, uri_dest => $cs->uri_dest->as_string
	};

	$hash_ptr->{$cs->name}{description} = $cs->description
		if $cs->description
	;
	
	$hash_ptr->{$cs->name}{uid} = $cs->posting_uid
		if $cs->posting_uid
	;

	if ( $cs->has_subsites ) {
		$hash_ptr->{$cs->name}{subsites} = {};
		hash_write( $hash_ptr->{$cs->name}{subsites}, $_) for @{$cs->subsites};
	}

}

use YAML;
YAML::DumpFile( 'cities.yaml', $db );

1;
