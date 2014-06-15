use Test::More;

use Game::Osero;
use Game::Osero::AI::Edge;

my $n = Game::Osero::BLANK;
my $b = Game::Osero::BLACK;
my $w = Game::Osero::WHITE;

subtest 'Stable' => sub {
    my $data1 = [
        $b,
        $b,
        $n,
        $n,
        $n,
        $w,
        $w,
        $w,
    ];
    is( Game::Osero::AI::Edge::State->new($data1, $b)->get_stable(), 2);
    is( Game::Osero::AI::Edge::State->new($data1, $w)->get_stable(), 3);

    my $data2 = [
        $w,
        $w,
        $w,
        $w,
        $w,
        $w,
        $w,
        $w,
    ];

    is( Game::Osero::AI::Edge::State->new($data2, $b)->get_stable(), 0);
    is( Game::Osero::AI::Edge::State->new($data2, $w)->get_stable(), 8);

    my $data3 = [
        $n,
        $n,
        $b,
        $w,
        $b,
        $w,
        $w,
        $w,
    ];
    is( Game::Osero::AI::Edge::State->new($data3, $b)->get_stable(), 0);
    is( Game::Osero::AI::Edge::State->new($data3, $w)->get_stable(), 3);

    my $data4 = [
        $b,
        $b,
        $b,
        $w,
        $b,
        $w,
        $b,
        $b,
    ];

    is( Game::Osero::AI::Edge::State->new($data4, $b)->get_stable(), 5);
    is( Game::Osero::AI::Edge::State->new($data4, $w)->get_stable(), 0);
};

subtest 'Wing Mountain' => sub {
    my $data1 = [
        $n,
        $b,
        $b,
        $b,
        $b,
        $b,
        $n,
        $n,
    ];
    is( Game::Osero::AI::Edge::State->new($data1, $b)->get_mountain(), 0);
    is( Game::Osero::AI::Edge::State->new($data1, $b)->get_wing(),     1);
    is( Game::Osero::AI::Edge::State->new($data1, $w)->get_mountain(), 0);
    is( Game::Osero::AI::Edge::State->new($data1, $w)->get_wing(),     0);

    my $data2 = [
        $n,
        $b,
        $b,
        $b,
        $b,
        $b,
        $w,
        $n,
    ];
    is( Game::Osero::AI::Edge::State->new($data2, $b)->get_mountain(), 0);
    is( Game::Osero::AI::Edge::State->new($data2, $b)->get_wing(),     0);
    is( Game::Osero::AI::Edge::State->new($data2, $w)->get_mountain(), 0);
    is( Game::Osero::AI::Edge::State->new($data2, $w)->get_wing(),     0);
    
    my $data3 = [
        $n,
        $b,
        $b,
        $b,
        $b,
        $b,
        $n,
        $b,
    ];
    is( Game::Osero::AI::Edge::State->new($data3, $b)->get_mountain(), 0);
    is( Game::Osero::AI::Edge::State->new($data3, $b)->get_wing(),     0);
    is( Game::Osero::AI::Edge::State->new($data3, $w)->get_mountain(), 0);
    is( Game::Osero::AI::Edge::State->new($data3, $w)->get_wing(),     0);

    my $data4 = [
        $n,
        $w,
        $w,
        $w,
        $w,
        $w,
        $w,
        $n,
    ];
    is( Game::Osero::AI::Edge::State->new($data4, $b)->get_mountain(), 0);
    is( Game::Osero::AI::Edge::State->new($data4, $b)->get_wing(),     0);
    is( Game::Osero::AI::Edge::State->new($data4, $w)->get_mountain(), 1);
    is( Game::Osero::AI::Edge::State->new($data4, $w)->get_wing(),     0);

    my $data5 = [
        $n,
        $w,
        $w,
        $w,
        $w,
        $w,
        $w,
        $w,
    ];
    is( Game::Osero::AI::Edge::State->new($data5, $b)->get_mountain(), 0);
    is( Game::Osero::AI::Edge::State->new($data5, $b)->get_wing(),     0);
    is( Game::Osero::AI::Edge::State->new($data5, $w)->get_mountain(), 0);
    is( Game::Osero::AI::Edge::State->new($data5, $w)->get_wing(),     0);
};

subtest 'index_line' => sub {
    my $data1 = [
            $b,
            $b,
            $b,
            $b,
            $b,
            $b,
            $b,
            $b,
        ];
    my $edge = new_ok('Game::Osero::AI::Edge');
    is($edge->line_index($data1), 6560);

    my $data2 = [
            $n,
            $n,
            $n,
            $n,
            $n,
            $n,
            $n,
            $n,
        ];
    is($edge->line_index($data2), 0);
};


subtest 'create_edge' => sub {
    my $osero = Game::Osero->new();

    $osero->set_board(
    [
        [ $b, $w, $w, $b, $n, $n, $n, $n ],
        [ $b, $w, $w, $b, $n, $n, $n, $n ],
        [ $b, $w, $w, $b, $n, $n, $n, $n ],
        [ $w, $w, $w, $b, $n, $n, $n, $b ],
        [ $b, $w, $w, $b, $n, $n, $n, $n ],
        [ $b, $w, $w, $b, $n, $n, $n, $n ],
        [ $b, $w, $w, $b, $n, $n, $n, $n ],
        [ $b, $n, $n, $n, $w, $b, $n, $n ],
    ]);

    my $edge = Game::Osero::AI::Edge->new();

    is_deeply ( $edge->create_top_edge($osero),    [ $b, $b, $b, $w, $b, $b, $b, $b] );
    is_deeply ( $edge->create_bottom_edge($osero), [ $n, $n, $n, $b, $n, $n, $n, $n] );
    is_deeply ( $edge->create_left_edge($osero),   [ $b, $w, $w, $b, $n, $n, $n, $n] );
    is_deeply ( $edge->create_right_edge($osero),  [ $b, $n, $n, $n, $w, $b, $n, $n] );
};

subtest 'add state' => sub {
    my $state = Game::Osero::AI::Edge::State->new( [ $n, $n, $n, $n, $n, $n, $n, $n ], $b );
    $state->set_wing(1);
    $state->set_mountain(2);
    $state->set_stable(3);
    $state->set_cdrop(4);

    my $sum_state = $state + $state;

    is ( $sum_state->get_wing,     2);
    is ( $sum_state->get_mountain, 4);
    is ( $sum_state->get_stable,   6);
    is ( $sum_state->get_cdrop,    8);
};


subtest 'evaluate state' => sub {
    my $osero = Game::Osero->new();

    $osero->set_board(
    [
        [ $n, $n, $b, $b, $b, $b, $b, $n ],
        [ $b, $w, $w, $b, $n, $n, $n, $b ],
        [ $b, $w, $w, $b, $n, $n, $n, $b ],
        [ $w, $w, $w, $b, $n, $n, $n, $b ],
        [ $b, $w, $w, $b, $n, $n, $n, $b ],
        [ $b, $w, $w, $b, $n, $n, $n, $b ],
        [ $b, $w, $w, $b, $n, $n, $n, $b ],
        [ $b, $b, $n, $n, $w, $b, $n, $n ],
    ]);


    my $ai = Game::Osero::AI::Edge->new();

    my $sum_state = $ai->evaluate_state($osero);

    is($sum_state->get_wing, 1);
    is($sum_state->get_mountain, 1);
    is($sum_state->get_stable, 5);
};

done_testing();
