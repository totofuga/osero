use strict;
use warnings;
use Test::More;
use Game::Osero;

# 開放度のテスト

my $osero = new_ok("Game::Osero");

is($osero->get_openrate->[0][0], 3);
is($osero->get_openrate->[0][1], 5);

is($osero->get_openrate->[3][3], 5);
is($osero->get_openrate->[2][2], 7);

$osero->drop(2, 3);
is($osero->get_openrate->[3][3], 4);

done_testing();
