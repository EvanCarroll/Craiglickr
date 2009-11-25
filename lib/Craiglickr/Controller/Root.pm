package Craiglickr::Controller::Root;
use strict;
use warnings;
use parent 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';

sub default :Path {
	my ( $self, $c ) = @_;
	$c->response->body( 'Page not found, maybe you want to check out <a href="/craiglickr">/craiglickr</a>' );
	$c->response->status(404);
}

sub end : ActionClass('RenderView') {}

1;
