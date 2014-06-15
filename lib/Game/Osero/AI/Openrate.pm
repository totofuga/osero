package Game::Osero::AI::Openrate;

use strict;
use warnings;

use Game::Osero;

use interface 'Game::Osero::AI';

sub new {
    my ($class) = @_;
    return bless {} , ref $class || $class;
}

sub evaluate {
    my ($self, $osero, $color) = @_;

    my $score = 0;
    for my $x ( 0..7 ) {
        for my $y ( 0..7 ) {
            next if $osero->get_board()->[$x][$y] == Game::Osero::BLANK;

            if ( $osero->get_board()->[$x][$y] == $color ) {
                $score += $osero->get_openrate()->[$x][$y];
            } else {
                $score -= $osero->get_openrate()->[$x][$y];
            }
        }
    }

    return $score;
}

1;
