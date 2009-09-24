package Craiglickr::CommunitySite;
use strict;
use warnings;

use Moose;
use MooseX::AttributeHelpers;
use HTML::TreeBuilder;
use URI;

use Craiglickr::UA;

has 'uri_orig' => ( isa => 'URI' , is => 'ro' , required => 1 );

has 'description' => ( isa => 'Str' , is => 'ro' );

## id (hun) is used for posting: https://post.craigslist.org/hum
has 'posting_uid' => (
	isa => 'Maybe[Str]'
	, is => 'ro'
	, lazy => 1
	, default => sub {
		my $self = shift;
	
		return undef if $self->subsites;
	
		my $uri = URI->new(
			$self->_response_root
			->look_down( id => 'postlks' )
			->look_down( _tag => 'a', href => qr/post\./ )
			->attr( 'href' )
		);
		my $path = URI->new($uri)->path;
		substr($path,0,1,'');
		$path;
	}
);

has 'name' => (
	isa       => 'Maybe[Str]'
	, is      => 'ro'
	, lazy    => 1
	, default => sub {
		my $self = shift;

		## XXX CRAIGSLIST BUG
		## http://geo.craigslist.org/iso/il
		## Craigslist bug, should be titled Isreael
		## Type should not permit undef
		return undef unless $self->_response_root->look_down( '_tag' => 'title' );

		my $title = $self->_response_root->look_down(_tag=>'title')->as_trimmed_text;
		$title =~ m/craigslist:\s+(.*?)\s+classifieds/;
		$1;
	}
);

has '_response_root' => (
	isa       => 'HTML::TreeBuilder'
	, is      => 'ro'
	, lazy    => 1
	, default => sub { HTML::TreeBuilder->new_from_content( $_[0]->_resp->content ) }
);

has 'subsites' => (
	isa         => 'ArrayRef[Craiglickr::CommunitySite] | Undef'
	, is        => 'ro'
	, metaclass => 'Collection::Array'
	, provides  => { 'push' => 'push_subsite' }
	, lazy      => 1
	, default   => sub {
		my $self = shift;

		my $list = $self->_response_root->look_down( _tag => 'div', id => 'list' );
		
		return undef unless $list;

		my @links = $list->look_down( _tag => 'a' );
		
		my @subsites;
		foreach my $element ( @links ) {
			push @subsites, $self->meta->new_object({
				name        => $element->as_trimmed_text
				, uri_orig  => URI->new( $element->attr('href') )
			});
		}
	
		\@subsites;
	}
);

has '_resp' => (
	isa       => 'HTTP::Response'
	, is      => 'ro'
	, lazy    => 1
	, default => sub {
		my $self = shift;
		my $ua = Craiglickr::UA->new;
		my $uri = $self->uri_orig;
		warn "$uri\n";
		return $ua->get( $uri );
	}
);

sub uri_dest { $_[0]->_resp->request->uri }

1;
