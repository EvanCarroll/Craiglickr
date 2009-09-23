package Craiglickr::Model::CraiglickrPost;
use feature ':5.10';
use mro 'c3';
use strict;
use warnings;

use base 'Catalyst::Model';

use Craiglickr::Post;

sub new {
	my ( $class, $c, $config ) = @_;

	Craiglickr::Post->new({
		cities   => $config->{cities} // []
		, boards => $config->{boards} // []
	});

}

1;
