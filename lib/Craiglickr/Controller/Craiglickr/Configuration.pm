package Craiglickr::Controller::Craiglickr::Configuration;
use strict;
use warnings;
use parent 'Catalyst::Controller';

sub view :Local {
	my ( $self , $c ) = @_;
	# use XXX; YYY $c->model('CraigsList')->locations_index_by_code;
	$c->stash->{template} = 'craiglickr/view_configuration.tt';
}

1;
