package Game::Osero::AI::Fixed;
use strict;
use warnings;

use interface 'Game::Osero::AI';
use Game::Osero;

use List::Util;

use constant FIXED_EVALUTION_VALUES => [
    [ 100, -40, 20,  5,  5, 20, -40, 100 ],
    [ -40, -80, -1, -1, -1, -1, -80, -40 ],
    [  20,  -1,  5,  1,  1,  5,  -1,  20 ],
    [   5,  -1,  1,  0,  0,  1,  -1,   5 ],
    [   5,  -1,  1,  0,  0,  1,  -1,   5 ],
    [  20,  -1,  5,  1,  1,  5,  -1,  20 ],
    [ -40, -80, -1, -1, -1, -1, -80, -40 ],
    [ 100, -40, 20,  5,  5, 20, -40, 100 ],
];

sub new {
    my ($class) = @_;
    my $class_name = ref $class || $class;

    return bless {}, $class_name;
}

sub evaluate {
    my ($class, $osero, $color) = @_;

    my $evaluate_value;

    $color = $osero->get_turn() unless defined $color;

    foreach my $x (0.. 7) {
        foreach my $y (0.. 7) {

            my $pos_color = $osero->get_board()->[$x][$y];

            next if ( $pos_color == Game::Osero::BLANK );

            if ( $pos_color == $color ) {
                $evaluate_value += FIXED_EVALUTION_VALUES->[$x][$y];
            } else {
                $evaluate_value -= FIXED_EVALUTION_VALUES->[$x][$y];
            }
        }
    }
    return $evaluate_value;
}

1;
