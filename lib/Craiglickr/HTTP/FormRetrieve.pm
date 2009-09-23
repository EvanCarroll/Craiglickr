package Craiglickr::HTTP::FormRetrieve;
use Moose;
use strict;
use warnings;

use feature ':5.10';
use HTML::TreeBuilder;
use URI;
use LWP;

use constant URI_HOSTNAME => URI->new( 'https://post.craigslist.org' );

use namespace::clean -except => 'meta';

## all codes
has [qw/ city section board /] => (
	isa  => 'Str'
	, is => 'ro'
	, trigger => \&_check_uri_or_prereq
);

has 'uri' => (
	isa  => 'URI'
	, is => 'ro'
	, lazy => 1
	, predicate => 'has_uri'
	, trigger => \&_check_uri_or_prereq
	, default => sub {
		my $self = shift;
		my $uri = URI_HOSTNAME->clone;
		$uri->path( join '/', $self->city, $self->section, $self->board );
		$uri;
	}
);

## E-mail anonymize is radio button, A=hide, C=anonymize
has 'form' => (
	isa => 'HTML::Element'
	, is => 'rw'
	, lazy => 1
	, default => sub {
		my $self = shift;

		my $ua = LWP::UserAgent->new;
		my $resp = $ua->get( $self->uri );

		open ( my $fh, ">", "output.html" )or die $!;
		print $fh $resp->content;
		warn $self->uri;

		my $form = HTML::TreeBuilder
			->new_from_content( $resp->content )
			->look_down(
				_tag => 'form'
				, id => 'postingForm'
			)
		;
		
		## get rid of parents
		$form->detach;

		my $post_uri = $self->uri->clone;
		$post_uri->path( $form->attr('action') );

		$form->attr('action', $post_uri->canonical );
		warn $form->attr('action');
	
		my @input = $form->look_down( _tag => 'div', class => 'title row' )
			->look_down( _tag => 'input', tabindex => 1, type => 'text' )
		;

		## type="hidden" class=> qr/sta|fr|gg1|point/;
		$input[0]->attr( id => "title" );
		$input[1]->attr( id => "price" );
		$input[2]->attr( id => "location" );
		
		$form->look_down( name => 'FromEMail' )->attr( id => "email1" );
		$form->look_down( name => 'ConfirmEMail' )->attr( id => "email2" );

		$form->look_down( _tag => 'textarea', tabindex => 1 )
			->attr( id => "description" )
		;

		{
			my @elements = $form->look_down( _tag=>'input', type=>'hidden', class=>qr/sta|fr|gg[12]|point|mand/ );
			foreach my $e ( @elements ) {
				given ( $e->address ) {
					when ( qr/^0.0.1(?:\.|$)/ ) { $e->attr('id','posPrePostingkey') }
					when ( qr/^0.2(?:\.|$)/ ) { $e->attr('id','posPreSubmit') }
				
					when ( '0.0.5.3.2' ) { $e->attr('id','posPreDescription') }
					when ( '0.0.5.4.2' ) { $e->attr('id','posPreDescription') }
					when ( '0.0.5.4.2.0' ) { $e->attr('id','posPreDescription') }
					when ( '0.0.5.9' ) { $e->attr('id','posPreDescription') }
					when ( '0.0.5.9.0' ) { $e->attr('id','posPreDescription') } ## confirmed
					when ( '0.0.5.10' ) { $e->attr('id','posPreDescription') } ## confirmed
					when ( '0.0.5.3.2.0' ) { $e->attr( 'id','posPreDescription') }
					when ( '0.0.7.3.2' ) { $e->attr('id','posPreDescription' ) }
					when ( '0.0.7.4.2' ) { $e->attr('id','posPreDescription') }
					when ( '0.0.7.9' ) { $e->attr('id','posPreDescription') }
					when ( '0.0.7.9.0' ) { $e->attr('id','posPreDescription') }
					when ( '0.0.7.10.0' ) { $e->attr('id','posPreDescription' ) }

					when ( qr/^0.0.[567].[10](?:\.|$)/ ) { $e->attr('id','posPreTitle') }
					## when ( '0.0.6.0.0.2' ) { $e->attr('id','posPreTitle') }
					## when ( '0.0.5.0' ) { $e->attr('id','posPreTitle') }
					## when ( '0.0.5.0.0.2.0' ) { $e->attr('id','posPreTitle') }
					## when ( '0.0.5.1.0.2.0' ) { $e->attr('id','posPreTitle') }
					## when ( '0.0.5.1.0.2' ) { $e->attr('id','posPreTitle') }
					## when ( '0.0.7.0.0' ) { $e->attr('id', 'posPreTitle') }
					## when ( '0.0.7.0' ) { $e->attr('id', 'posPreTitle') }
					## when ( '0.0.7.1.0.2' ) { $e->attr('id', 'posPreTitle' ) }
					default { use XXX; YYY [ $e->attr('id'), $e->attr('class'), $e->address ] }
				}
			}
		}

		return $form;
	
	}

);

sub get_token_as_html_from_form_pos {
	my ( $self, $formPos ) = @_;
	my $e = $self->form->look_down(_tag=>'input',id=>'posPre'.ucfirst($formPos));
	$e ? sprintf ('<div class="posToken">%s</div>', $e->as_HTML) : undef;
}

sub get_image_add {
	my $self = shift;
	
	$self->form->look_down(
		'_tag'=>'input'
		, sub {
			my $element = $_[0];
			return 1
				if $element->attr('type') eq 'file'
				or $element->attr('type') eq 'hidden' && $element->attr('value') eq 'add'
			;
			0;
		}
	);

}

sub BUILD { $_[0]->_check_uri_or_prereq }

sub _check_uri_or_prereq {
	my $self = shift;
	unless ( $self->has_uri or $self->city && $self->section && $self->board ) {
		throw_error( sprintf(
			"Please either configure %s with (city, section, and board) so it can make a URI, or supply a URI\n"
			, __PACKAGE__
		));
	}
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Craiglickr::HTTP::FormRetrieve

=head1 DESCRIPTION

This module takes a city/section/board, and generates a URI with it. With the URI, we (a) downloads the URL (b) parses out the form, (c) optionally present the form with data from L<Craiglickr::Ad>

It is B<required> that you either supply the city, section, board, or the URI.

=over 12

=item uri()

=item city()

=item section()

=item board()

=back

=cut
