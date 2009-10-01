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

sub locations :Chained('craiglickr') :CaptureArgs(1) {
	my ( $self, $c, $locations ) = @_;
	$c->stash->{'locations'} = [split /,/, $locations];
}

sub configureLocations :Chained('craiglickr') :PathPart('locations') :Args(0) {
	my ( $self, $c ) = @_;
	
	if ( my %p = %{$c->request->params} ) {
		my %unique;
		$unique{$_}=undef for @{$p{loc}};
		$c->res->redirect(
			$c->uri_for( $self->action_for('configureBoards'), [join ',', keys %unique] )
		);
	}
	else {
		$c->stash->{craigslist}{locations} = $c->model('CraigsList')->locations;
		$c->stash->{template} = 'locations.tt';
	}

}

sub boards :Chained('locations') :Args(1) {
	my ( $self, $c, $boards ) = @_;
	$c->stash->{'boards'} = [split /,/, $boards];
	
	$c->stash->{posts} = Craiglickr::Post->new({
			locations   => $c->stash->{locations}
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

sub configureBoards :Chained('locations') :PathPart('boards') :Args(0) {
	my ( $self, $c ) = @_;
	use XXX; XXX $c->model('Craigslist')->for_sale;
	$c->stash->{template} = 'configure.tt';
}

sub default :Path {
	my ( $self, $c ) = @_;
	$c->response->body( 'Page not found, maybe you want to check out <a href="/craiglickr">/craiglickr</a>' );
	$c->response->status(404);
}

sub end : ActionClass('RenderView') {}

1;
