package Craiglickr::Controller::Craiglickr;
use strict;
use warnings;
use parent 'Catalyst::Controller';

use Craiglickr::Ad;
use Craiglickr::Post;

sub craiglickr :Chained :CaptureArgs(0) { }

sub index :Chained('craiglickr') :PathPart('') :Args(0) {
	my ( $self, $c ) = @_;
	$c->stash->{template} = 'craiglickr/home.tt';
}

## Both of these are chained from craiglickr /craiglickr/locations craiglickr/locations/foo
sub configureLocations :Chained('craiglickr') :PathPart('locations') :Args(0) {
	my ( $self, $c ) = @_;

	if ( $c->req->params->{loc} ) {
		my %p = %{$c->req->params};
		## They get sent as an array in catalyst if they are in the form loc=foo&loc=bar
		$p{loc} = [$p{loc}] unless ref $p{loc} eq 'ARRAY';

		my %unique;
		$unique{$_}=undef for @{$p{loc}};
		$c->res->redirect(
			$c->uri_for(
				$self->action_for('configureBoards')
				, [join ',', keys %unique]
				, $c->req->query_params
			)
		);

	}
	else {
		$c->stash->{craigslist}{locations} = $c->model('CraigsList')->locations;
		$c->stash->{template} = 'craiglickr/setup/locations.tt';
	}

}

sub locations :Chained('craiglickr') :CaptureArgs(1) {
	my ( $self, $c, $locations ) = @_;
	my @locations = split /,/, $locations;

	## No 0 locations
	die 'No locations supplied' unless @locations ;

	if ( @locations > 1 ) {

		## No posting cross-city unless permitted
		die 'Cross-posting to different locations disabled'
			if $c->config->{Craiglickr}{location}{cross_posting} == 0
		;

		my %l;

		## No dupe locations
		for my $loc ( @locations ) {
			! exists $l{$loc}
				? $l{$loc} = undef
				: die "Can not post to the same location twice as tried with $loc"
			;
		}

		## No dupe metro
		if ( $c->config->{Craiglickr}{location}{cross_metro} == 0 ) {
			my %metro;
			for my $loc ( keys %l ) {
				$loc =~ s/-.*//;
				! exists $metro{$loc}
					? $metro{$loc} = undef
					: die "Can not post to the same location twice as tried with $loc"
				;
			}
		}

		## No exceeding max locations
		if ( @locations > $c->config->{Craiglickr}{location}{max} ) {
			my $max = $c->config->{Craiglickr}{location}{max};
			my $supplied = @locations;
			die "Can only post to $max locations at a time. You tried to post to $supplied locations";
		}

	}

	## No invalid locations
	foreach my $loc ( @locations ) {

		my $linfo = $c->model('Craigslist')->locations_index_by_code->{$loc};

		die "Invalid location [$loc]"
			unless defined $linfo
		;

		## Finallize in stash
		push @{ $c->stash->{locations} }, $linfo;
	}

	## Flush this data to cookies if set in config
	if ( $c->config->{Craiglickr}{cookies} ) {
		$c->res->cookies->{default_locations} = { value => join ',', map $_->{uid}, @{$c->stash->{locations}} };
	}

	$c->stash->{locations};

}

## Both boards are end points /locations/foo/boards/bar /locations/foo/boards
sub configureBoards :Chained('locations') :PathPart('boards') :Args(0) {
	my ( $self, $c ) = @_;

	if ( $c->req->params->{cat} ) {
		my %p = %{$c->req->params};
		## They get sent as an array in catalyst if they are in the form loc=foo&loc=bar
		$p{cat} = [$p{cat}] unless ref $p{cat} eq 'ARRAY';

		my %unique;
		$unique{$_}=undef for @{$p{cat}};
		$c->res->redirect(
			$c->uri_for(
				$self->action_for('boards')
				, $c->request->captures
				, (join ',', keys %unique)
				, $c->req->query_params
			)
		);

	}
	else {
		$c->stash->{craigslist}{section}{s} = $c->model('Craigslist')->for_sale;
		$c->stash->{template} = 'craiglickr/setup/type/catagory/forsale.tt';
	}

}

sub boards :Chained('locations') :Args(1) {
	my ( $self, $c, $boards ) = @_;
	my @boards = split /,/, $boards;

	if ( @boards > 1 ) {

		die 'Cross-posting to different boards is disabled'
			if $c->config->{Craiglickr}{board}{cross_posting} == 0
		;

		## No dupe locations
		my %b;
		for my $board ( @boards ) {
			! exists $b{$board}
				? $b{$board} = undef
				: die "Can not post to the same board twice as tried with $board"
			;
		}

		## No exceeding max boards
		if ( @boards > $c->config->{Craiglickr}{board}{max} ) {
			my $max = $c->config->{Craiglickr}{board}{max};
			my $supplied = @boards;
			die "Can only post to $max boards at a time. You tried to post to the '$supplied' board";
		}

	}

	foreach my $boards ( @boards ) {
		push @{ $c->stash->{boards} }
			, $c->model('Craigslist')->for_sale_by_code($boards)
		;
	}

	## Flush this data to cookies if set in config
	if ( $c->config->{Craiglickr}{cookies} ) {
		$c->res->cookies->{default_boards} = { value => join ',', map $_->{code}, @{$c->stash->{boards}} };
	}

	$c->detach( $self->action_for('post') );

}

sub post :Local {
	my ( $self, $c ) = @_;

	## Try to set the posts from the cookie data
	if (
		! defined $c->stash->{locations}
		&& ! defined $c->stash->{boards}
		and $c->config->{Craiglickr}{cookies}
	) {
		if ( $c->req->cookie('default_locations') and $c->req->cookie('default_boards') ) {
			$c->go(
				'/craiglickr/boards'
				, [ $c->req->cookie('default_locations')->value ]
				, [ $c->req->cookie('default_boards')->value ]
			);
		}
		else {
			$c->res->redirect(
				$c->uri_for( '/craiglickr/locations', $c->req->mangle_params )
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

sub end : ActionClass('RenderView') {}

1;
