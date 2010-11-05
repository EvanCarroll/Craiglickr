package Craiglickr::Post;
use feature ':5.10';
use mro 'c3';
use strict;
use warnings;
use namespace::autoclean;

use Moose;

use Craiglickr::HTTP::FormRetrieve;
use Craiglickr::Ad;

has 'locations' => (
	isa  => 'ArrayRef[Str]'
	, is => 'ro'
	, default => sub { +[] }

	, traits  => ['Array']
	, handles => { 'add_location' => 'push' }
);

has 'boards' => (
	isa  => 'ArrayRef[Str]'
	, is => 'ro'
	, default => sub { +[] }

	, traits  => ['Array']
	, handles => { 'add_board' => 'push' }
);

sub get_forms {
	my $self = shift;

	my @forms;
	foreach my $location ( @{$self->locations} ) {
		foreach my $board ( @{$self->boards} ) {

			my $form = Craiglickr::HTTP::FormRetrieve->new({
				location => $location
				, board   => $board
				, section => 'S'
			});
			push @forms, $form;

		}
	}

	\@forms;

}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Craiglickr::Post

=head1 DESCRIPTION

Object that prep a post to Craigslist.

Stores an array of locations to post to and an array of boards to post to, and then works by calling ->get_form, which will return a list of valid L<Craiglickr::HTTP::FormRetrieve>s.

=head1 Methods

=over 12

=item post( sub { my $form = shift; ... } )

=item new_ad()

=item add_location()

=item add_board()

=back

=cut
