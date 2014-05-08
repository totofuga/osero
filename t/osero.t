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


sub pos_sort {
    if ( $a->[0] == $b->[0] ) {
        return $a->[1] <=> $b->[1]
    } else {
        return $a->[0] <=> $b->[0];
    }
}

# 置けるところのリスト取得
my @can_drop_pos = ([3, 2], [2, 3], [5, 4], [4, 5]);

is_deeply([ sort pos_sort @{$osero->get_can_drop_pos()} ], [sort pos_sort @can_drop_pos] );

# 現在の手番
is($osero->get_turn, Game::Osero::BLACK);
is($osero->get_rival_turn, Game::Osero::WHITE);

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
