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

## id (hum) is used for posting: https://post.craigslist.org/hum
has 'posting_uid' => (
	isa => 'Maybe[Str]'
	, is => 'ro'
	, lazy => 1
	, default => sub {
		my $self = shift;
	
##		use Digest::MD5 'md5_hex';
##		my $md5 = md5_hex( $self->_resp->content );
##		open ( my $fh, '>', "out/" . time() . "_$md5.html" ) or die;
##		print $fh $self->_resp->content;
		
		my $uid;
		if ( my $postlks = $self->_response_root->look_down( id => 'postlks' ) ) {
			my $href = $postlks->look_down( _tag => 'a', href => qr/post\./ )->attr( 'href' );
			my $path = URI->new($href)->path;
			substr($path,0,1,'');
			$uid = $path;
		}
		$uid
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
	isa         => 'ArrayRef[Craiglickr::CommunitySite]'
	, is        => 'ro'
	, metaclass => 'Collection::Array'
	, provides  => { 'push' => 'push_subsite', 'empty' => 'has_subsites' }
	, lazy      => 1
	, predicate => 'preset_subsites'
	, default   => sub {
		my $self = shift;

		my ( $list, @subsites );
		if ( $list = $self->_response_root->look_down( _tag => 'div', id => 'list' ) ) {
			
			my @links = $list->look_down( _tag => 'a' );
			
			warn sprintf ("SS: Dedicated-list variant %s added for %s\n", scalar @links, $self->uri_dest);
			
			foreach my $element ( @links ) {
				push @subsites, $self->meta->new_object({
					name        => $element->as_trimmed_text
					, uri_orig  => URI->new( $element->attr('href') )
				});
			}
		
		}
		
		## Lets get those sub-craiglists too, http://dallas.craigslist.org/ftw
		elsif ( $list = $self->_response_root->look_down( _tag => 'span', class => 'for' ) ) {
			## Stop infinate recursion with subsites
			## breadcrumb thing on a subsite, points to other subsites, which point back, etc.
			return [] if $self->uri_orig->path =~ /\w{3,}/;
		
			my @links = $list->look_down( _tag => 'a' );
	
			warn sprintf ("SS: Sector variant %s added for %s\n", scalar @links, $self->uri_dest);

			foreach my $element ( @links ) {
				my $name = $element->attr('href');
				$name =~ tr'\/''d;

				my $uri = URI->new( $self->uri_dest );
				$uri->path( $element->attr('href') );
				use XXX; YYY [{
					posting_uid => $self->posting_uid . "-$name"
					, uri_orig  => $uri
					, name      => $element->attr('title')
				}];

				push @subsites, $self->meta->new_object({
					posting_uid => $self->posting_uid . "-$name"
					, uri_orig  => $uri
					, name      => $element->attr('title')
				});
			}
			
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
