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

auto_install;

WriteAll;

