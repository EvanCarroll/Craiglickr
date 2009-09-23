package Craiglickr::Controller::Root;
use strict;
use warnings;
use parent 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';
use Craiglickr::Ad;

sub index :Path :Args(0) {
	my ( $self, $c ) = @_;

	$c->stash->{posts} = $c->model('CraiglickrPost')->get_forms;

	$c->stash->{ad} = Craiglickr::Ad->new({
		title         => 'Test Vehicle'
		, location    => 'Kingwood, TX'
		, description => 'THIS CAR IS AWESOME'
		, price       => 1_000 + 500
		, email       => 'me@evancarroll.com'
		, email_flag  => 'anonymous'
	});

	$c->stash->{template} = 'index.html';
}

sub default :Path {
	my ( $self, $c ) = @_;
	$c->response->body( 'Page not found' );
	$c->response->status(404);
}

sub end : ActionClass('RenderView') {}

1;
