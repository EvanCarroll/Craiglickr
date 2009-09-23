package Craiglickr::Types;
use MooseX::Types -declare => [qw/Money EmailFlag/];
use MooseX::Types::Moose qw( Str Int );

enum EmailFlag , qw( hidden unhidden anonymous );

##
## Money
##
subtype Money
	, as Str
	, where { defined $_ && /^(?:\d+(?:\.\d*)?|\.\d+)$/ }
	, message { "Invalid money: [ $_[0] ]" }
;
coerce Money
	, from Str , \&monify
	, from Int , \&monify
;

sub monify {
	my $money = shift;

	$money =~ s/[^0-9.-]+//g;

	$money = 0 unless length $money;

	##unless ( $money =~ /^(?:\d+(?:\.\d*)?|\.\d+)$/ ) {
	$money = sprintf( "%.02f", $money )
		if defined $money
	;
	##}

	$money

}

1;

=head1 NAME

Craiglickr::Types

=head1 DESCRIPTION

This is just a simple collection of L<MooseX::Types> that we use elsewhere.

=head2 Types

=over 12

=item Money - has Coercion

=item EmailFlag

=back

=cut
