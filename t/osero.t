use strict;
use warnings;
use Test::More;
use Osero;

my $osero = Osero->new();

is($osero->get_board()->[0][0], Osero::BLANK);

is($osero->get_board()->[3][3], Osero::WHITE);
is($osero->get_board()->[4][3], Osero::BLACK);
is($osero->get_board()->[4][4], Osero::WHITE);
is($osero->get_board()->[3][4], Osero::BLACK);

done_testing;
