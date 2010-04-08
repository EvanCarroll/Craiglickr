package Craiglickr::Controller::Craiglickr::Locations::Boards;
use strict;
use warnings;
use parent 'Catalyst::Controller';

## Both boards are end points /locations/foo/boards/bar /locations/foo/boards
sub configure :Chained('/craiglickr/locations/locations') :PathPart('boards') :Args(0) {
	my ( $self, $c ) = @_;

	if ( $c->req->params->{cat} ) {
		my %p = %{$c->req->params};
		## They get sent as an array in catalyst if they are in the form loc=foo&loc=bar
		$p{cat} = [$p{cat}] unless ref $p{cat} eq 'ARRAY';

		my %unique;
		$unique{$_}=undef for @{$p{cat}};
		$c->res->redirect(
			$c->uri_for(
				$c->controller('Craiglickr::Locations::Boards')->action_for('boards')
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

sub boards :Chained('/craiglickr/locations/locations') :Args(1) {
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

	$c->detach(
		$c->controller('Craiglickr')->action_for('post')
	);

}

sub end : ActionClass('RenderView') {}

1;
