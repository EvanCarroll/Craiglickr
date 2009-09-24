package Craiglickr::UA;
use strict;
use warnings;

use base 'LWP::UserAgent';
use URI;

## This is here so we can keep with english titles and urls
sub redirect_ok{
	my ( $self, $prospective_request, $response ) = @_;

	my $uri = $prospective_request->uri;
	
	## Sometimes we get redirected from en. to non en.
	## and sometimes we're getting redirected to an en. per cl
	unless (
		$response->request->uri =~ m'[.]en[.]craigslist'
		|| $prospective_request->uri =~ m'[.]en[.]craigslist'
	) {
		$uri =~ s'(?:\.\w{2})?[.]craigslist[.]'.en.craigslist.';
		$prospective_request->uri( URI->new($uri) );
	}

	1;
}

1;
