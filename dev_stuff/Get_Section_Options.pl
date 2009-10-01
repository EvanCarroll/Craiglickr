#!/usr/bin/env perl
use strict;
use warnings;

use LWP;
use URI;
use HTML::TreeBuilder;

use YAML;

use feature ':5.10';

my $ua = LWP::UserAgent->new;


foreach my $cat ( qw/S/ ) {

	my %data;
	my $uri = URI->new( "http://post.craigslist.org/sfo/$cat/" );
	say $uri;

	my $resp = $ua->get( $uri );

	my $http = HTML::TreeBuilder->new_from_content( $resp->content );

	my @lis = $http
		->look_down( _tag => 'table', summary => 'category picker' )
		->look_down( _tag => 'li' )
	;

	foreach my $li ( @lis ) {
		my @p = $li->look_down( _tag => 'p' );
		if ( @p ) {	$_->delete for @p }


		my $a = $li->look_down( _tag => 'a' );

		my $href = $a->attr( 'href' );
		$href =~ m'.*/(.*?)/';
		my $code = $1;

		my $text = $li->as_trimmed_text;

		$text =~ s/\s* \( \s* (.*?) \s* \) \s* //x;
		my $comment = $1;
		
		$data{$code} = { code => $code, text => $text };
		
		$data{$code}{comment} ||= $1 if $1 ne $code;
		
	}

	YAML::DumpFile( "$cat.yaml", \%data );

}

1;
