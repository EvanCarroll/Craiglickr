use Craiglickr::Post;

my $clp = Craiglickr::Post->new;

$clp->add_city( 'hou' );
$clp->add_city( 'elp' );
$clp->add_board( 'ctd' );

foreach (  1  ) {
	my $vehc = {
		title         => 'Test Vehicle'
		, location    => 'Kingwood, TX'
		, description => 'THIS CAR IS AWESOME'
		, price       => 1_000_000 + $_
		, email       => 'me@evancarroll.com'
		, email_flag  => 'anonymous'
	};
	$clp->new_ad( $vehc );
};

#use Craiglickr::HTTP::FormRetrieve;
#my $clfr = Craiglickr::HTTP::FormRetrieve->new({
#	city    => 'hou'
#	, board => 'ctd'
#	, section => 'S'
#});

die $clp->post;
$|++;
