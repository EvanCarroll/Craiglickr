#!/usr/bin/env perl
use strict;
use warnings;

use Craiglickr::SiteListing;

my $db = {};
foreach my $cs ( @{ Craiglickr::SiteListing->new->directory} ) {
	hash_write( $db, $cs );
}

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

	if ( defined $cs->subsites ) {
		$hash_ptr->{$cs->name}{subsites} = {};
		hash_write( $hash_ptr->{$cs->name}{subsites}, $_) for @{$cs->subsites};
	}

}

use YAML;
YAML::DumpFile( 'cities.yaml', $db );

1;
