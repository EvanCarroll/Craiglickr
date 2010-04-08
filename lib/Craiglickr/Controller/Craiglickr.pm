package Craiglickr::Controller::Craiglickr;
use strict;
use warnings;
use parent 'Catalyst::Controller';

use Craiglickr::Ad;
use Craiglickr::Post;

__PACKAGE__->config->{namespace} = '';

sub craiglickr :Chained :CaptureArgs(0) { }

sub index :Chained('/craiglickr') :PathPart('') :Args(0) {
	my ( $self, $c ) = @_;
	$c->stash->{template} = 'craiglickr/home.tt';
}

sub post :Chained('/craiglickr') :Args(0) {
	my ( $self, $c ) = @_;

	## Try to set the posts from the cookie data
	if (
		! defined $c->stash->{locations}
		&& ! defined $c->stash->{boards}
		and $c->config->{Craiglickr}{cookies}
	) {
		if ( $c->req->cookie('default_locations') and $c->req->cookie('default_boards') ) {
			$c->go(
				'/craiglickr/locations/boards/boards'
				, [ $c->req->cookie('default_locations')->value ]
				, [ $c->req->cookie('default_boards')->value ]
			);
		}
		else {
			$c->res->redirect(
				$c->uri_for_action(
					'/craiglickr/locations/configure'
					, $c->request->captures
					, $c->req->params
				)
			);
		}
	}

	$c->stash->{posts} = Craiglickr::Post->new({
		locations => [ map $_->{uid},  @{$c->stash->{locations}} ]
		, boards  => [ map $_->{code}, @{$c->stash->{boards}}    ]
	})->get_forms;

	$c->stash->{ad} = Craiglickr::Ad->new({
		title         => 'Test Item'
		, location    => 'Kingwood, TX'
		, description => 'THIS ITEM IS AWESOME'
		, price       => 1_000 + 500
		, email       => 'user@domain.com'
		, email_flag  => 'anonymous'
	});

	$c->stash->{template} = 'craiglickr/post.tt';

}

sub wtf :Local { use XXX; XXX $_[1]->dispatcher->_action_hash() };

sub end : ActionClass('RenderView') {}

1;
