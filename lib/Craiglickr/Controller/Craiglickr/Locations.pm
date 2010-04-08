package Craiglickr::Controller::Craiglickr::Locations;
use strict;
use warnings;
use parent 'Catalyst::Controller';

## Both of these are chained from craiglickr /craiglickr/locations craiglickr/locations/foo
sub configure :Chained('/craiglickr') :PathPart('locations') :Args(0) {
	my ( $self, $c ) = @_;

	if ( $c->req->params->{loc} ) {
		my %p = %{$c->req->params};
		## They get sent as an array in catalyst if they are in the form loc=foo&loc=bar
		$p{loc} = [$p{loc}] unless ref $p{loc} eq 'ARRAY';

		my %unique;
		$unique{$_}=undef for @{$p{loc}};
		$c->res->redirect(
			$c->uri_for(
				$c->controller('Craiglickr::Locations::Boards')->action_for('configure')
				, [join ',', keys %unique]
				, ()
				, $c->req->query_params
			)
		);

	}
	else {
		$c->stash->{craigslist}{locations} = $c->model('CraigsList')->locations;
		$c->stash->{template} = 'craiglickr/setup/locations.tt';
	}

}

sub locations :Chained('/craiglickr') :CaptureArgs(1) {
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
		my %l;
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

sub end : ActionClass('RenderView') {}

1;
