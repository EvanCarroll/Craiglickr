package Craiglickr::V::AdControlPanel;
use Moose;
use strict;
use warnings;

use Template;

use namespace::clean -except => 'meta';

has 'forms' => (
	isa => 'ArrayRef[Craiglickr::V::TemplatePost]'
	, is => 'ro'
	, required => 1
);

my $html =<<EOF;
<html>
	<head><title> Craigslist Ad Control Center </title></head>
	<body>
		<div style="background-color:white; padding 10px">
		[%- FOREACH form IN forms %]
			[%- form.as_HTML %]
		[% END %]
		</div>
	</body>
</html>
EOF

sub as_HTML {
	my $self = shift;

	my $tt = Template->new;
	my $output;
	$tt->process( \$html, { forms => $self->forms }, \$output );
	print $output;

}

__PACKAGE__->meta->make_immutable;

1;
