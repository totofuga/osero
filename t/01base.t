use strict;
use warnings;

use Test::More;
use Game::Osero::AI::Fixed;
use Game::Osero;

*BLANK = \&Game::Osero::BLANK;
*BLACK = \&Game::Osero::BLACK;
*WHITE = \&Game::Osero::WHITE;

my $osero = Game::Osero->new();

$osero->set_board(
[
    [ BLACK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), WHITE(), ], 
    [ BLACK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), WHITE(), ],
    [ BLACK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), WHITE(), ],
    [ BLACK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), WHITE(), ],
    [ BLACK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), WHITE(), ],
    [ BLACK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), WHITE(), ],
    [ BLACK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), WHITE(), ],
    [ BLACK(), BLANK(), BLANK(), BLANK(), BLANK(), BLANK(), BLACK(), BLACK(), ],
]);


my $fixed_ai = new_ok('Game::Osero::AI::Fixed');
is($fixed_ai->evaluate($osero), 160);
$osero->set_turn($osero->get_rival_turn);
is($fixed_ai->evaluate($osero), -160);

done_testing();
