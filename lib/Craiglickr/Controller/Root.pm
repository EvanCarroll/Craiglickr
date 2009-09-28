package Craiglickr::Controller::Root;
use strict;
use warnings;
use parent 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';

use Craiglickr::Ad;
use Craiglickr::Post;

sub craiglickr :Chained('.') :CaptureArgs(0) { }

sub configureAll :Chained('craiglickr') :PathPart('') :Args(0) {
	my ( $self, $c ) = @_;
	$c->stash->{template} = 'configure.tt';
}

sub cities :Chained('craiglickr') :CaptureArgs(1) {
	my ( $self, $c, $cities ) = @_;
	$c->stash->{'cities'} = [split /,/, $cities];
}

sub configureCities :Chained('craiglickr') :PathPart('cities') :Args(0) {
	my ( $self, $c ) = @_;
	$c->stash->{cities} = $c->model('CraiglickrCities')->db;
	$c->stash->{template} = 'cities.tt';

}

sub boards :Chained('cities') :Args(1) {
	my ( $self, $c, $boards ) = @_;
	$c->stash->{'boards'} = [split /,/, $boards];
	
	$c->stash->{posts} = Craiglickr::Post->new({
			cities   => $c->stash->{cities}
			, boards => $c->stash->{boards}
	})->get_forms;
	
	$c->stash->{ad} = Craiglickr::Ad->new({
		title         => 'Test Vehicle'
		, location    => 'Kingwood, TX'
		, description => 'THIS CAR IS AWESOME'
		, price       => 1_000 + 500
		, email       => 'me@evancarroll.com'
		, email_flag  => 'anonymous'
	});

	$c->stash->{template} = 'post.tt';
}

sub configureBoards :Chained('cities') :PathPart('boards') :Args(0) {
	my ( $self, $c ) = @_;
	$c->stash->{template} = 'configure.tt';
}

sub default :Path {
	my ( $self, $c ) = @_;
	$c->response->body( 'Page not found, maybe you want to check out <a href="/craiglickr">/craiglickr</a>' );
	$c->response->status(404);
}

sub end : ActionClass('RenderView') {}

1;
