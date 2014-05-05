use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'osero';
all_from 'lib/Osero.pm';
author   q{藤田善光 <fujita.yoshihiko@gmail.com>};
license  'artistic2';

perl_version 5.006;

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#osero',
   license    => 'http://www.perlfoundation.org/artistic_license_2_0',
   #repository => 'git://github.com/藤田善光/osero.git',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=osero',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
   'Class::Accessor::Fast' => 0.34,
);

install_as_cpan;
auto_install;
WriteAll;
