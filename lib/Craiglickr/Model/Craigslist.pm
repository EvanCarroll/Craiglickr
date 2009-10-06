package Craiglickr::Model::Craigslist;
use feature ':5.10';
use mro 'c3';
use strict;
use warnings;

use Moose;

extends 'Catalyst::Model';

use File::ShareDir;
use File::Spec;
use YAML;

has 'locations_only' => ( isa => 'Str', is => 'ro' );
has 'locations_crop' => ( isa => 'Str', is => 'ro', default => 0 );

has 'for_sale' => (
	isa  => 'HashRef'
	, is => 'ro'
	, lazy => 1 ## required for some weird fucking reason
	, default => sub {
		my $self = shift;
		my $abs_path = File::ShareDir::dist_file('Craiglickr', 'S.yaml' );
	 	my $hash = YAML::LoadFile( $abs_path );

		$hash;
	}
);

has 'locations' => (
	isa  => 'HashRef'
	, is => 'ro'
	, lazy => 1 ## required for some weird fucking reason
	, default => sub {
		my $self = shift;
		my $abs_path = File::ShareDir::dist_file('Craiglickr', 'locations.yaml' );
	 	my $hash = YAML::LoadFile( $abs_path );

		if ( $self->locations_only and $self->locations_crop ) {
			$hash = delete $hash->{ $self->locations_only };
			$hash = $hash->{subsites};
		}
		elsif ( $self->locations_only ) {
			delete $hash->{$_} foreach grep $_ ne $self->locations_only, keys %$hash;
		}

		$hash;
	}
);

1;
