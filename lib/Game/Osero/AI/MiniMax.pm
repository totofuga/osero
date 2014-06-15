package Game::Osero::AI::MiniMax;
use strict;
use warnings;

use base qw|Class::Accessor::Fast|;
use Clone qw(clone);

use List::Util qw(min max);

__PACKAGE__->mk_accessors(qw|evaluator|);

sub max_level {
    my ($self, $limit, $osero, $color, $alpha, $beta) = @_;

    if ( $limit <= 0 ) {
        return $self->evaluator->evaluate($osero, $color);
    }

    my $can_drop_pos = $osero->get_can_drop_pos();

    my $max_evaluate_value;


#    @$can_drop_pos =
#        map  { $_->[1] }
#        sort { $b->[0] <=> $a->[0] } 
#        map  {
#            my $calc_osero = clone $osero;
#            $calc_osero->drop($_->[0], $_->[1]);
#            [
#                $self->evaluator->evaluate($calc_osero, $color),
#                $_
#            ]; 
#        } @$can_drop_pos;

    foreach my $pos (@$can_drop_pos) {

        my $calc_osero = clone $osero;
        $calc_osero->drop($pos->[0], $pos->[1]);
        $calc_osero->set_turn($calc_osero->get_rival_turn);

        my $evaluate_value = $self->min_level($limit - 1, $calc_osero, $color, $alpha, $beta);

        if ( defined $beta && $evaluate_value >= $beta ) {
            return $evaluate_value;
        }

        if ( !defined $max_evaluate_value || ( $max_evaluate_value < $evaluate_value )) {
            $max_evaluate_value = $evaluate_value;

            unless ( defined $alpha ) {
                $alpha = $evaluate_value;
            } else {
                $alpha = max ( $alpha, $evaluate_value );
            }
        }
    }

    return $max_evaluate_value;
}

sub min_level {
    my ($self, $limit, $osero, $color, $alpha, $beta) = @_;

    if ( $limit <= 0 ) {
        return $self->evaluator->evaluate($osero, $color);
    }

    my $can_drop_pos = $osero->get_can_drop_pos();

#    @$can_drop_pos =
#        map  { $_->[1] }
#        sort { $a->[0] <=> $b->[0] } 
#        map  {
#            my $calc_osero = clone $osero;
#            $calc_osero->drop($_->[0], $_->[1]);
#            [
#                $self->evaluator->evaluate($calc_osero, $color),
#                $_
#            ]; 
#        } @$can_drop_pos;

    my $min_evaluate_value;
    foreach my $pos (@$can_drop_pos) {

        my $calc_osero = clone $osero;
        $calc_osero->drop($pos->[0], $pos->[1]);
        $calc_osero->set_turn($calc_osero->get_rival_turn);

        my $evaluate_value = $self->max_level($limit - 1, $calc_osero, $color, $alpha, $beta);

        if ( defined $alpha && $evaluate_value <=  $alpha ) {
            return $evaluate_value;
        }

        if ( !defined $min_evaluate_value || ( $min_evaluate_value > $evaluate_value )) {
            $min_evaluate_value = $evaluate_value;

            unless ( defined $beta ) {
                $beta = $evaluate_value;
            } else {
                $beta = min ( $beta, $evaluate_value );
            }
        }
    }

    return $min_evaluate_value;
}


1;
