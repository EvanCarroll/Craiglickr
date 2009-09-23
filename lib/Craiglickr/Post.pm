package Craiglickr::Post;
use Moose;
use strict;
use warnings;

use MooseX::AttributeHelpers;
use Craiglickr::HTTP::FormRetrieve;
use Craiglickr::Ad;

use namespace::clean -except => 'meta';

has 'cities' => (
	isa  => 'ArrayRef[Str]'
	, is => 'ro'
	, default => sub { +[] }

	, metaclass => 'Collection::Array'
	, provides => { 'push' => 'add_city' }
);

has 'boards' => (
	isa  => 'ArrayRef[Str]'
	, is => 'ro'
	, default => sub { +[] }

	, metaclass => 'Collection::Array'
	, provides => { 'push' => 'add_board' }
);

sub get_forms {
	my $self = shift;

	my @forms;
	foreach my $city ( @{$self->cities} ) {
		foreach my $board ( @{$self->boards} ) {

			my $form = Craiglickr::HTTP::FormRetrieve->new({
				city => $city
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

Object that prep a post to craigslist, stores Cities to post to, and an array of Boards to post to, and then works by calling ->new_ad();

=head1 Methods

=over 12

=item post( sub { my $form = shift; ... } )

=item new_ad()

=item add_city()

=item add_board()

=back

=cut
