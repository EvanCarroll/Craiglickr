package Craiglickr::Model::CraiglickrCities;
use feature ':5.10';
use mro 'c3';
use strict;
use warnings;

use Moose;

extends 'Catalyst::Model';

use File::ShareDir;
use File::Spec;
use YAML;

has 'only' => ( isa => 'Str', is => 'ro' );
has 'crop' => ( isa => 'Str', is => 'ro', default => 0 );

has 'db' => (
	isa  => 'HashRef'
	, is => 'ro'
	, lazy => 1 ## required for some weird fucking reason
	, default => sub {
		my $self = shift;
		my $abs_path = File::ShareDir::dist_file('Craiglickr', 'cities.yaml' );
	 	my $hash = YAML::LoadFile( $abs_path );

		if ( $self->only and $self->crop ) {
			$hash = delete $hash->{ $self->only };
			$hash = $hash->{subsites};
		}
		elsif ( $self->only ) {
			delete $hash->{$_} foreach grep $_ ne $self->only, keys %$hash;
		}

		$hash;
	}
);

1;
