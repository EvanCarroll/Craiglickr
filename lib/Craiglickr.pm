package Craiglickr;

use warnings;
use strict;

our $VERSION = '1.999_009';

use Craiglickr::Post;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use parent qw/Catalyst/;
use Catalyst qw/
	-Debug
	ConfigLoader
	Static::Simple
/;

# Configure the application.
#
# Note that settings in craiglickr.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config( name => 'Craiglickr' );

# Start the application
__PACKAGE__->setup();

1;

__END__

=head1 NAME

Craiglickr - A free open source Craigslist posting tool.

=head1 DESCRIPTION

This is a Catalyst-based Craigslist posting tool. There 

=head1 SYNOPSIS

	#!/usr/bin/env perl
	use strict;
	use warnings;

	my $cl = Craigslist->new;
	
	my $p = $cl->new_post({ cities => [qw/hou/], boards => [qw/ctd/] });
	$p->add_city( 'sfo' );

	$p->new_ad({
		title => $title
		, location   => 'Kingwood, Texas'
		, description => 'Check out this advertisment~!!!!!'
		, price      => 10_000
		, email      => 'me+cpan@evancarroll.com'
		, email_flag => 'anonymous'
	});

=head1 SEE ALSO

L<Craiglickr::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Evan Carroll, C<< <me at evancarroll.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-craiglickr at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Craiglickr>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

perldoc Craiglickr


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Craiglickr>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Craiglickr>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Craiglickr>

=item * Search CPAN

L<http://search.cpan.org/dist/Craiglickr/>

=head1 CAVEAT LEGALITY

This is not a I<posting agent>! It is a I<posting tool>. Any post submitted will leave your
computer, and subsequently be stamped with your ip address.

The term Craigslist is not owned by me. I use the service and generally dislike
the idea of this tool. However, the methods used by this program are, afaik legal.
This tool does *NOT* intentionally circumvent limits imposed by Craigslist, nor
does it read or process captchas.

Craigslist could prevent this tool entirely, by simply using a captcha in every
step of the event process. They however don't. Furthermore, numerious attempts to
contact Craigslist have proven futile.

There are many Craiglist posting tools like this that I'm aware of. This one is
simply a free version -- use it at your own risk. Make, no assumption about the
Craigslist terms of service read it yourself.

Craigslist is the name of corporation and proprietary service found craigslist.com.
This is simply a perl library to ease posting to that service, the IP of the
final submission is that of client of Craiglickr.

=head1 COPYRIGHT & LICENSE

All code not explicitly marked otherwise is Copyright 2009 Evan Carroll CC-BY-SA version 3.0 or greater.
You can find the available license at L<http://creativecommons.org/licenses/by-sa/3.0/>.

This program is currently using, and distributed with, B<CKeditor> which is being used under an unspecified license. You can find more information at http://ckeditor.com/license. CKeditor is a great easy to use WYSIWYG form, please check it out.

=cut
