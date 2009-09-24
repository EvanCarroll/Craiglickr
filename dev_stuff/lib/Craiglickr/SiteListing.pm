package Craiglickr::SiteListing;
use Moose;
use strict;
use warnings;

use LWP;
use URI;
use HTML::TreeBuilder;

use Craiglickr::CommunitySite;

has 'isocodes' => (
	isa => 'HashRef'
	, is => 'ro'
	, lazy => 1
	, default => sub {
		my %hash;
		while ( <DATA> ) {
			chomp;
			my ( $country, $region, $name ) = split /,/, $_;
			$hash{$country}{$region} = $name;
		}
		\%hash;
	}
);

has 'directory' => (
	isa       => 'ArrayRef[Craiglickr::CommunitySite]'
	, is      => 'ro'
	, default => sub {
		my $self = shift;
		my $ua = LWP::UserAgent->new;
		my $uri = URI->new( "http://www.craigslist.org/about/sites" );
		
		my $resp = $ua->get( $uri );
		my $http = HTML::TreeBuilder->new_from_content( $resp->content );


		## Get the list of from all of the world's ISO from the main craigslist directory
		## This will exclude US and CA, because they are sub-subed
		## It will also exclude, http://geo.craigslist.org/iso -- because they suck
		my @boards;

		@boards = map Craiglickr::CommunitySite->new({ uri_orig => URI->new($_->attr('href')) })
			, $http->look_down(
				_tag => 'a'
				, href => qr(http://geo.craigslist.org/iso/\w{2}\Z)
			)
		;

 	## ones without iso codes
		push @boards
			, Craiglickr::CommunitySite->new({
				uri_orig => URI->new('http://geo.craigslist.org/iso')
			})
		;
		
		foreach my $country ( ({abbr=>'ca',name=>'Canada'},{abbr=>'us',name=>"United States"}) ) {
			my $uri = 'http://geo.craigslist.org/iso/'.$country->{abbr}.'/';

			my @country_boards = map
				Craiglickr::CommunitySite->new( uri_orig=>URI->new($_), description => $self->_get_name(URI->new($_)) )
				, map $_->attr('href'), $http->look_down(
					_tag   => 'a'
					, href => qr($uri)
				)
			;
			
			my $countrylist = Craiglickr::CommunitySite->new({
				name          => $country->{name}
				, description => sprintf( "All %s boards", $country->{name} )
				, uri_orig    => URI->new($uri)
				, subsites    => \@country_boards
			});

			push @boards, $countrylist;
		
		}

		\@boards;

	}

);

sub _get_name {
	my ( $self, $uri ) = @_;
	my $path = $uri->clone->path;
	my @segments = split '\/', $path;
	shift @segments; ## should get rid of iso;

	my $name;

	my $is_iso = shift @segments;
	if ( $is_iso eq 'iso' ) {

		my $country_code = shift @segments;

		my $country_name;
		if ( $country_code =~ /ca/i ) {
			$country_name = "Canada";
		}
		elsif ( $country_code =~ /us/i ) {
			$country_name = "United States"
		}

		if ( $country_name ) {
			my $region_code = shift @segments;
			my $region_name = $self->isocodes->{uc $country_code}{uc $region_code};
			$name = "$region_name, $country_name";
		}
	
	}

	$name;

}


1;

__DATA__
CA,AB,Alberta
CA,BC,British Columbia
CA,MB,Manitoba
CA,NB,New Brunswick
CA,NL,Newfoundland
CA,NS,Nova Scotia
CA,NU,Nunavut
CA,ON,Ontario
CA,PE,Prince Edward Island
CA,QC,Quebec
CA,SK,Saskatchewan
CA,NT,Northwest Territories
CA,YT,Yukon Territory
US,AA,Armed Forces Americas
US,AE,Armed Forces Europe, Middle East, & Canada
US,AK,Alaska
US,AL,Alabama
US,AP,Armed Forces Pacific
US,AR,Arkansas
US,AS,American Samoa
US,AZ,Arizona
US,CA,California
US,CO,Colorado
US,CT,Connecticut
US,DC,District of Columbia
US,DE,Delaware
US,FL,Florida
US,FM,Federated States of Micronesia
US,GA,Georgia
US,GU,Guam
US,HI,Hawaii
US,IA,Iowa
US,ID,Idaho
US,IL,Illinois
US,IN,Indiana
US,KS,Kansas
US,KY,Kentucky
US,LA,Louisiana
US,MA,Massachusetts
US,MD,Maryland
US,ME,Maine
US,MH,Marshall Islands
US,MI,Michigan
US,MN,Minnesota
US,MO,Missouri
US,MP,Northern Mariana Islands
US,MS,Mississippi
US,MT,Montana
US,NC,North Carolina
US,ND,North Dakota
US,NE,Nebraska
US,NH,New Hampshire
US,NJ,New Jersey
US,NM,New Mexico
US,NV,Nevada
US,NY,New York
US,OH,Ohio
US,OK,Oklahoma
US,OR,Oregon
US,PA,Pennsylvania
US,PR,Puerto Rico
US,PW,Palau
US,RI,Rhode Island
US,SC,South Carolina
US,SD,South Dakota
US,TN,Tennessee
US,TX,Texas
US,UT,Utah
US,VA,Virginia
US,VI,Virgin Islands
US,VT,Vermont
US,WA,Washington
US,WV,West Virginia
US,WI,Wisconsin
US,WY,Wyoming
