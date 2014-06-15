package Game::Osero::AI::Edge;

use strict;
use warnings;
use base qw(Class::Accessor::Fast);

use interface 'Game::Osero::AI';
use Game::Osero;

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors(
    qw( black_state_table white_state_table )
);

use List::Util qw(sum);

use constant {
       DEF_STABLE_FACTOR =>   60,
       DEF_WING_FACTOR   =>  -20,
       DEF_MOUNTAIN_FACTOR => -1,
};


sub new {
    my $class = shift;


    my $self = $class->SUPER::new(@_);

    $self->set_black_state_table( [] );
    $self->set_white_state_table( [] );
    $self->_calc_state_table([]);

    return $self;
}

sub evaluate {
    my ($self, $osero, $color) = @_;

    $color = $osero->get_turn() unless defined $color;

    my $state = $self->evaluate_state($osero, $color);

    my $rival_color = Game::Osero::BLACK;
    if ( $color == Game::Osero::BLACK ) { 
        $rival_color = Game::Osero::WHITE;
    }
    my $rival_state = $self->evaluate_state($osero, $rival_color);



    return $state->get_stable() * DEF_STABLE_FACTOR +
           $state->get_wing() * DEF_WING_FACTOR +
           $state->get_mountain() * DEF_MOUNTAIN_FACTOR -
           $rival_state->get_stable() * DEF_STABLE_FACTOR -
           $rival_state->get_wing() * DEF_WING_FACTOR -
           $rival_state->get_mountain() * DEF_MOUNTAIN_FACTOR;
}

sub evaluate_state {
    my ($self, $osero, $color) = @_;

    $color = $osero->get_turn() unless defined $color;

    my $edge_list = [
        $self->create_top_edge($osero),
        $self->create_bottom_edge($osero),
        $self->create_left_edge($osero),
        $self->create_right_edge($osero),
    ];

    my $state;
    if ( $color == Game::Osero::BLACK ) { 
        $state = sum map { $self->get_black_state_table()->[$self->line_index($_)] } @$edge_list;
    } else {
        $state = sum map { $self->get_white_state_table()->[$self->line_index($_)] } @$edge_list;
    }

    # 角のstableが重複するので取り除く
    for ( 
        $osero->get_board()->[0][0], 
        $osero->get_board()->[0][7],
        $osero->get_board()->[7][0],
        $osero->get_board()->[7][7],
    ) {
        if ( $_ == $color ) {
            $state->set_stable( $state->get_stable() - 1 );
        }
    }

    return $state;

}

sub _calc_state_table {
    my ($self, $edge_data) = @_;

    if ( @$edge_data == 8 ) {
        my $line_index = $self->line_index($edge_data);
        $self->get_black_state_table->[$line_index] 
            = Game::Osero::AI::Edge::State->new($edge_data, Game::Osero::BLACK);

        $self->get_white_state_table->[$line_index] 
            = Game::Osero::AI::Edge::State->new($edge_data, Game::Osero::WHITE);
        return;
    }

    my @store_edge_data = @$edge_data;

    $self->_calc_state_table( [ @store_edge_data, Game::Osero::BLACK] );
    $self->_calc_state_table( [ @store_edge_data, Game::Osero::WHITE] );
    $self->_calc_state_table( [ @store_edge_data, Game::Osero::BLANK] );
}

sub line_index {
    my ($class, $edge_data) = @_;

    return 3 * ( 3 * ( 3 * ( 3 * ( 3 * ( 3 * ( ( 3 * $edge_data->[0] ) +
        $edge_data->[1]) +
        $edge_data->[2]) +
        $edge_data->[3]) +
        $edge_data->[4]) +
        $edge_data->[5]) +
        $edge_data->[6]) +
        $edge_data->[7];
}

sub create_top_edge {
    my ($self, $osero) = @_;
    return [ map { $_->[0] } @{$osero->get_board()} ];
}

sub create_bottom_edge {
    my ($self, $osero) = @_;
    return [ map { $_->[7] } @{$osero->get_board()} ];
}

sub create_left_edge {
    my ($self, $osero) = @_;
    return $osero->get_board()->[0];
}

sub create_right_edge {
    my ($self, $osero) = @_;
    return $osero->get_board()->[7];
}

package Game::Osero::AI::Edge::State;

use strict;
use warnings;
use base qw(Class::Accessor::Fast);

use Clone qw(clone);

use overload 
        '+' => \&_add,
        fallback => 1;


use Game::Osero;

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors(
    qw( wing mountain stable cdrop )
);

sub new {
    my $class      = shift;
    my $edge_data  = shift;
    my $color      = shift;

    my $self = $class->SUPER::new(@_);
    $self->_initialize($edge_data, $color);

    return $self;
}

sub _initialize {
    my ($self, $edge_data, $color) = @_;

    $self->_calc_stable($edge_data, $color);
    $self->_calc_wing_mountain($edge_data, $color);
}

sub _calc_stable {
    my ($self, $edge_data, $color) = @_;

    my $stable_cnt = 0;
    for ( @$edge_data ) {
        last unless ( $_ == $color );
        ++$stable_cnt
    }

    if ( $stable_cnt != @$edge_data ) {
        for ( reverse @$edge_data ) {
            last unless ( $_ == $color );
            ++$stable_cnt
        }
    }

    $self->set_stable($stable_cnt);
}

sub _calc_wing_mountain {
    my ($self, $edge_data, $color) = @_;

    $self->set_wing(0);
    $self->set_mountain(0);

    # 角がうまっていれば違う
    return unless ( $edge_data->[0] == Game::Osero::BLANK && $edge_data->[7] == Game::Osero::BLANK );

    # すべてのB or Aが自分の色である
    foreach ( 2..5 ) {
        return unless $edge_data->[$_] == $color;
    }

    # ウィング判定
    if ( $edge_data->[1] == $color             && $edge_data->[6] == Game::Osero::BLANK ||
         $edge_data->[1] == Game::Osero::BLANK && $edge_data->[6] == $color ) {

        $self->set_wing(1);

    # 山判定
    } elsif ( $edge_data->[1] == $color && $edge_data->[6] == $color ) {

        $self->set_mountain(1);
    }
}

sub _add {
    my ($lth, $rth) = @_;
    my $ret = clone($lth);
    for ( keys %{$ret} ) {
        $ret->{$_} += $rth->{$_};
    }

    return $ret;
}

1;
