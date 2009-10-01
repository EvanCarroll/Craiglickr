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

has 'config' => (
	isa  => 'HashRef'
	, is => 'ro'
	, required => 1
);

has 'db' => (
	isa  => 'HashRef'
	, is => 'ro'
	, lazy => 1 ## required for some weird fucking reason
	, default => sub {
		my $self = shift;
		my $abs_path = File::ShareDir::dist_file('Craiglickr', 'cities.yaml' );
	 	my $hash = YAML::LoadFile( $abs_path );

		if ( exists $self->config->{only} ) {
			delete $hash->{$_} foreach grep $_ ne $self->config->{only}, keys %$hash;
		}

		$hash;
	}
);

sub BUILDARGS { return { config => $_[2] } }

1;
