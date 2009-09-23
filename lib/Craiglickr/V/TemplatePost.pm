package Craiglickr::V::TemplatePost;
use Moose;
use strict;
use warnings;

use URI;
use constant URI => URI->new('https://post.craigslist.org');

use namespace::clean -except => 'meta';

has 'form' => (
	isa  => 'Craiglickr::HTTP::FormRetrieve'
	, is => 'ro'
	, required => 1
);

has 'ad' => ( isa => 'Craiglickr::Ad' , is => 'ro' , required => 1 );

sub as_HTML {
	my $self = shift;

	my $form = $self->form->form;

	my $postURI = URI->clone;
	$postURI->path( $form->attr('action') );
	$form->attr( action => $postURI );
	
	$form->look_down( id => 'title' )->attr( value => $self->ad->title );
	$form->look_down( id => 'price' )->attr( value => $self->ad->price );
	$form->look_down( id => 'location' )->attr( value => $self->ad->location );
	
	$form->look_down( id => 'email1' )->attr( value => $self->ad->email );
	$form->look_down( id => 'email2' )->attr( value => $self->ad->email );

	$form->look_down( id => 'description' )
		->push_content( $self->ad->description )
	;
	
	my @inputs = $form->look_down( _tag => sub { $_[0] eq 'input' || $_[0] eq 'f );

	foreach ( @inputs ) {
		warn "good";
		printf ( "\nname:%s\t\tvalue:%s", $_->attr('name'), $_->attr('value') );
	}


}

__PACKAGE__->meta->make_immutable;

1;
