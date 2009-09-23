package Craiglickr::Ad;
use Moose;
use strict;
use warnings;

use MooseX::Types::Email 'EmailAddress';
use Craiglickr::Types qw(:all);

use namespace::clean -execpt => 'meta';

has [qw/ title location description /] => (
	isa        => 'Str'
	, is       => 'ro'
	, required => 1
);

has 'price' => (
	isa  => Money
	, is => 'ro'
	, required => 1
	, coerce   => 1
);

has 'email' => ( isa  => EmailAddress , is => 'ro' , required => 1 );

has 'email_flag' => (
	isa  => EmailFlag
	, is => 'rw'
	, required => 1
);

1;

__END__

=head1 NAME

Craiglickr::Ad

=head1 DESCRIPTION

L<Craiglickr> Object that represents one posting to Craigslist.

Thus far, I've noticed that all Craigslist.com postings have this information, except free which is represented as an explicit $0.00.

=head2 Methods

=over 12

=item title( $text )

=item location( $text )

=item description( $text )

=item price( $money )

$0.00 is free.

=item email_flag( 'anonymous' | 'hidden' | 'unhidden' )

=back

=cut
