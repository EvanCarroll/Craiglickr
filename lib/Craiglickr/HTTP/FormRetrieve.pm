package Craiglickr::HTTP::FormRetrieve;
use strict;
use warnings;
use feature ':5.10';

use Moose;
use Catalyst::Exception;
use HTML::TreeBuilder;
use URI;
use LWP;

use constant URI_HOSTNAME => URI->new( 'https://post.craigslist.org' );

use namespace::clean -except => 'meta';

## all codes
has [qw/ location section board /] => (
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
		my ( $location, $sublocation ) = split '-', $self->location;
		$uri->path( join '/', $location, $self->section, $self->board, $sublocation // 'none' );
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

		unless ( $form ) {
			Catalyst::Exception->throw(
				message => 'Critical error! Craigslist is not responding in a friendly fashion. '
			);
		}
		
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

		## maxlength=70  == title
		## maxlength=7   == price
		## maxlength=40  == location
		## if we don't have it (in the event of free), the next box=40 is going to be location
		if ( $input[1]->attr('maxlength') == 7 ) {
			$input[1]->attr( id => "price" );
			$input[2]->attr( id => "location" );
		}
		elsif ( $input[1]->attr('maxlength') == 40 ) {
			$input[1]->attr( id => "location" );
		}
		
		$form->look_down( name => 'FromEMail' )->attr( id => "email1" );
		$form->look_down( name => 'ConfirmEMail' )->attr( id => "email2" );

		$form->look_down( _tag => 'textarea', tabindex => 1 )
			->attr( id => "description" )
		;

		my @fields_total  = $form->look_down( _tag => qr/input|textarea/ );
		my @fields_hidden = $form->look_down( _tag=>'input', type=>'hidden', class=>qr/sta|fr|gg[12]|point|mand/ );


		## Marks hidden fields in the class of "posPre$idOfNextDefinitiveElement"...
		foreach my $hidden ( @fields_hidden ) {

			given ( $hidden->address ) {
				when ( qr/^0\.0\.1(?:\.|$)/ ) {
					$hidden->attr('class','posPrePostingkey');
					next;
				}
				when ( qr/^0\.2(?:\.|$)/ ) {
					$hidden->attr('class','posPreSubmit');
					next;
				}

				default {

					for ( my $i = 0; $i < $#fields_total; $i++ ) {
						if ( $fields_total[$i]->address eq $hidden->address ) {

							$i++ until !defined $fields_total[$i+1]->attr('type') || $fields_total[$i+1]->attr('type') ne 'hidden';

							my $id = 'posPre' .ucfirst( $fields_total[$i+1]->attr('id') );
							$hidden->attr('class', $id);
						}
					}

				}
			}

		}

		return $form;
	
	}

);

sub get_value_by_name { $_[0]->form->look_down(_tag=>'input',name=>$_[1])->attr('value') }

sub get_token_as_html_from_form_pos {
	my ( $self, $formPos ) = @_;
	my @e = $self->form->look_down(_tag=>'input',class=>'posPre'.ucfirst($formPos));

	my $e = '';
	$e .= $_->as_HTML for @e;
	$e ? "<div class=\"posToken\">$e</div>" : undef;

}

sub get_image_add {
	my $self = shift;
	
	my @image_section = $self->form->look_down(
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

	$_->attr('id',undef) for @image_section;

	\@image_section

}

sub BUILD { $_[0]->_check_uri_or_prereq }

sub _check_uri_or_prereq {
	my $self = shift;
	unless ( $self->has_uri or $self->location && $self->section && $self->board ) {
		throw_error( sprintf(
			"Please either configure %s with (location, section, and board) so it can make a URI, or supply a URI\n"
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

This module takes a location/section/board, and generates a URI with it. With the URI, we (a) downloads the URL (b) parses out the form, (c) mark the form up by setting ids, and classes which will make it easier to handle.

It is B<required> that you either supply the location, section, board; or, the URI.

=over 12

=item uri()

=item location()

=item section()

=item board()

=back

=cut
