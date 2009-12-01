package Craiglickr::Controller::Craiglickr;
use strict;
use warnings;
use parent 'Catalyst::Controller';

use Craiglickr::Ad;
use Craiglickr::Post;

sub craiglickr :Chained :CaptureArgs(0) { }

sub configureAll :Chained('craiglickr') :PathPart('') :Args(0) {
	my ( $self, $c ) = @_;
	$c->stash->{template} = 'configure.tt';
}

sub view_configuration :Path {
	my ( $self , $c ) = @_;
	# use XXX; YYY $c->model('CraigsList')->locations_index_by_code;
	$c->stash->{template} = 'craiglickr_configuration.tt';
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
	
	$c->stash->{locations};

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

	$c->detach( $self->action_for('post') );
	
}

sub post :Private {
	my ( $self, $c ) = @_;
	
	$c->stash->{posts} = Craiglickr::Post->new({
		locations => [map $_->{uid}, @{$c->stash->{locations}}]
		, boards  => [map $_->{code}, @{$c->stash->{boards}}]
	})->get_forms;
	
	$c->stash->{ad} = Craiglickr::Ad->new({
		title         => 'Test Item'
		, location    => 'Kingwood, TX'
		, description => 'THIS ITEM IS AWESOME'
		, price       => 1_000 + 500
		, email       => 'user@domain.com'
		, email_flag  => 'anonymous'
	});

	$c->stash->{template} = 'post.tt';
}

sub end : ActionClass('RenderView') {}

1;
