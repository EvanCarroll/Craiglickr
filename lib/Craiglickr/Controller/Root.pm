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
	my @locations = split /,/, $locations;

	## No 0 locations
	die 'No locations supplied' unless @locations ;
	
	if ( @locations > 1 ) {
		
		## No posting cross-city unless permitted
		die 'Cross-posting to different locations disabled'
			if $c->config->{Craiglickr}{location}{cross_posting} == 0
		;
	
		## No dupe locations
		my %loc;
		for my $loc ( @locations ) {
			! exists $loc{$loc}
				? $loc{$loc} = undef
				: die( "Can not post to the same location twice as tried with $loc" )
			;
		}

		## No dupe metro
		if ( $c->config->{Craiglickr}{location}{cross_metro} == 0 ) {
			my %metro;
			for my $loc ( keys %loc ) {
				$loc =~ s/-.*//;
				! exists $metro{$loc}
					? $metro{$loc} = undef
					: die( "Can not post to the same location twice as tried with $loc" )
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
		die "Invalid location [$loc]" unless exists $c->model('Craigslist')->locations_index_by_code->{$loc};
	}
	
	$c->stash->{'locations'} = \@locations;

}

sub configureLocations :Chained('craiglickr') :PathPart('locations') :Args(0) {
	my ( $self, $c ) = @_;
	
	if ( my %p = %{$c->request->params} ) {
		$p{loc} = [$p{loc}] unless ref $p{loc} eq 'ARRAY';

		my %unique;
		$unique{$_}=undef for @{$p{loc}};
		$c->res->redirect(
			$c->uri_for( $self->action_for('configureBoards'), [join ',', keys %unique] )
		);

	}
	else {
		$c->stash->{craigslist}{locations} = $c->model('CraigsList')->locations;
		$c->stash->{template} = 'setup/locations.tt';
	}

}

sub boards :Chained('locations') :Args(1) {
	my ( $self, $c, $boards ) = @_;
	my @boards = split /,/, $boards;
		
	if ( @boards > 1 and $c->config->{Craiglickr}{category}{cross_posting} == 0 ) {
		die 'Cross-posting to different catagories disabled'
	}

	$c->stash->{posts} = Craiglickr::Post->new({
			locations => $c->stash->{locations}
			, boards  => \@boards
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

	if ( my %p = %{$c->request->params} ) {
		$p{cat} = [$p{cat}] unless ref $p{cat} eq 'ARRAY';

		my %unique;
		$unique{$_}=undef for @{$p{cat}};
		$c->res->redirect(
			$c->uri_for( $self->action_for('boards'), $c->request->captures, join ',', keys %unique )
		);

	}
	else {
		$c->stash->{craigslist}{section}{s} = $c->model('Craigslist')->for_sale;
		$c->stash->{template} = 'setup/type/catagory/forsale.tt';
	}

}

sub configuration :Chained('craiglickr') :Args(0) {
	my ( $self , $c ) = @_;
	#	use XXX; YYY $c->model('CraigsList')->locations_index_by_code;
	$c->stash->{template} = 'craiglickr_configuration.tt';
}

sub default :Path {
	my ( $self, $c ) = @_;
	$c->response->body( 'Page not found, maybe you want to check out <a href="/craiglickr">/craiglickr</a>' );
	$c->response->status(404);
}

sub end : ActionClass('RenderView') {}

1;
