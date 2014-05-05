use strict;
use warnings;
use Test::More;
use Osero;

my $osero = Osero->new();

# 初期化確認
is($osero->get_board()->[0][0], Osero::BLANK);

is($osero->get_board()->[3][3], Osero::WHITE);
is($osero->get_board()->[4][3], Osero::BLACK);
is($osero->get_board()->[4][4], Osero::WHITE);
is($osero->get_board()->[3][4], Osero::BLACK);

# 現在の手番
is($osero->get_turn, Osero::BLACK);
is($osero->get_rival_turn, Osero::WHITE);

# 駒を置けるかどうかの確認
ok(  $osero->can_drop(3, 2));
ok(! $osero->can_drop(2, 2));

done_testing;
