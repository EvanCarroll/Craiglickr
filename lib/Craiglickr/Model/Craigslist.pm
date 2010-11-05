package Craiglickr::Model::Craigslist;
use feature ':5.10';
use mro 'c3';
use strict;
use warnings;
use namespace::autoclean;

use Moose;
use MooseX::ClassAttribute;
extends 'Catalyst::Model';

use File::ShareDir;
use File::Spec;
use YAML;

has 'locations_only' => ( isa => 'Str', is => 'ro' );
has 'locations_crop' => ( isa => 'Str', is => 'ro', default => 0 );

class_has 'for_sale' => (
	isa  => 'HashRef'
	, is => 'ro'
	, traits => ['Hash']
	, handles => { 'for_sale_by_code' => 'get' }
	, lazy => 1 ## required for some weird reason
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
		## required for some weird reason
		## the attributes are not set from config prior
	, lazy => 1
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

has 'locations_index_by_code' => (
	isa => 'HashRef'
	, is => 'ro'
	, lazy => 1
	, default => sub {
		my $self = shift;
		my $h = $self->locations;
		my $codes = {};
		_recurse_and_add_to_codes( $h, $codes );
		$codes;
	}
);

sub _recurse_and_add_to_codes {
	my ( $hash , $codes ) = @_;

	foreach my $hash ( values %$hash ) {
		if ( exists $hash->{subsites} ) {
			_recurse_and_add_to_codes( $hash->{subsites}, $codes );
		}
		else {
			$codes->{$hash->{uid}} = $hash;
		}
	}

}

__PACKAGE__->meta->make_immutable;
