use inc::Module::Install;

name     'Craiglickr';
all_from 'lib/Craiglickr.pm';
author   q{Evan Carroll <me@evancarroll.com>};
license  'perl';

build_requires 'Test::More';

requires 'namespace::clean';
requires 'LWP';
requires 'URI';
requires 'MooseX::AttributeHelpers';
requires 'HTML::TreeBuilder';
requires 'MooseX::Types';
requires 'MooseX::Types::Email';
requires 'File::ShareDir';

requires 'IO::Socket::SSL';

test_requires 'Test::More' => 0.94;

install_share 'share';

resources(
	'license',      => 'http://creativecommons.org/licenses/by-sa/3.0/'
	, 'homepage',   => 'http://www.evancarroll.com/'
	, 'repository', => 'git://github.com/EvanCarroll/Craiglickr.git'
);

auto_install;

WriteAll;

