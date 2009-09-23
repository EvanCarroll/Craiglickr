#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Craiglickr' );
}

diag( "Testing Craiglickr $Craiglickr::VERSION, Perl $], $^X" );
