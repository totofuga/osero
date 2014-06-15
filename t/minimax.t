use strict;
use warnings;
package DummyOsero;
use base qw|Class::Accessor::Fast|;

__PACKAGE__->mk_accessors(qw|tree|);

sub get_can_drop_pos {
    my ($self) = @_;
    my @pos_list;
    my $cnt = $self->tree()->getChildCount();
    foreach( 0..  $cnt -1 ) {
        push @pos_list, [$_, $_];
    }
    return \@pos_list;
}

sub drop {
    my ($self, $x, $y) = @_;
    $self->tree($self->tree->getChild($x));
}

sub set_turn {
}

sub get_rival_turn{
}

package DummyEvaluator;

use base qw|Class::Data::Inheritable|;
__PACKAGE__->mk_classdata('EVALUATE_COUNT' => 0);

sub new {
    return bless {}, shift;
}

sub evaluate {
    my ($self, $osero, $color, $cnt) = @_;

    unless ( $cnt ) {
    $self->EVALUATE_COUNT($self->EVALUATE_COUNT() + 1);
    }

    return $osero->tree()->getNodeValue();
}

package main;
use Test::More;

use Game::Osero::AI::MiniMax;

BEGIN {
    use_ok('Game::Osero::AI::MiniMax');
};

my $min_max = new_ok('Game::Osero::AI::MiniMax');


use Tree::Simple;
use Data::TreeDumper;

my $tree = Tree::Simple->new('', Tree::Simple->ROOT);
my $data = [
                -3, 
                [ 
                    [-5, [15, -3, 8]  ], 
                    [-6, [3, -8, 20]  ], 
                    [-7, [-9, -7, 18] ], 
                ],
            ];

mk_tree($data, $tree);

my $osero = DummyOsero->new({ tree => $tree });
$osero->tree();
my $evaluator = DummyEvaluator->new();
my $minmax = Game::Osero::AI::MiniMax->new({ evaluator => $evaluator });
my $state = $minmax->max_level(2, $osero, 0);
is($state, -3);

is(DummyEvaluator->EVALUATE_COUNT(), 17);

sub mk_tree {
    my ($data, $parent) = @_;

    if ( ref $data eq 'ARRAY' ) { 
        my $node_data = $data->[0];
        my $child_list = $data->[1];
        foreach ( @$child_list ) {
            my $child = Tree::Simple->new($node_data, $parent);
            mk_tree($_, $child);
        }
    } else {
        $parent->setNodeValue($_);
    }
}

done_testing();
