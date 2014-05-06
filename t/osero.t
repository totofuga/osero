use strict;
use warnings;
use Test::More;
use Game::Osero;

my $osero = Game::Osero->new();

# 初期化確認
is($osero->get_board()->[0][0], Game::Osero::BLANK);

is($osero->get_board()->[3][3], Game::Osero::WHITE);
is($osero->get_board()->[4][3], Game::Osero::BLACK);
is($osero->get_board()->[4][4], Game::Osero::WHITE);
is($osero->get_board()->[3][4], Game::Osero::BLACK);

# 現在の手番
is($osero->get_turn, Game::Osero::BLACK);
is($osero->get_rival_turn, Game::Osero::WHITE);

# 駒を置けるかどうかの確認
ok(  $osero->can_drop(3, 2));
ok(! $osero->can_drop(2, 2));

# 駒を置く
is($osero->drop(3,2), 1);
is($osero->get_board()->[3][2], Game::Osero::BLACK);
is($osero->get_board()->[3][3], Game::Osero::BLACK);

ok(! $osero->is_end());

# すべて黒にする
$osero->get_board()->[4][4] = Game::Osero::BLACK;
ok($osero->is_end());

# すべて埋め尽くす
for my $x (0..7) {
    for my $y (0..7) {
        $osero->get_board()->[$x][$y] = ($x + $y) % 2 == 0 ? Game::Osero::BLACK : Game::Osero::WHITE;
    }
}
ok($osero->is_end());

done_testing;
