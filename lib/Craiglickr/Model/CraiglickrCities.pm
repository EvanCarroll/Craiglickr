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

has 'db' => (
	isa => 'HashRef'
	, is => 'ro'
	, default => sub {
		my $abs_path = File::ShareDir::dist_file('Craiglickr', 'cities.yaml' );
		YAML::LoadFile( $abs_path );
	}
);

1;
