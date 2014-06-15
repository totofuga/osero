#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Game::Osero::AI' ) || print "Bail out!\n";
}

diag( "Testing Game::Osero::AI $Game::Osero::AI::VERSION, Perl $], $^X" );
