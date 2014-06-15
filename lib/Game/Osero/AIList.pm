package Game::Osero::AIList;
use strict;
use warnings;

use base qw| Class::Accessor::Fast |;
use List::MoreUtils qw(natatime);

__PACKAGE__->mk_accessors(qw| evaluator_to_frequency |);

sub new {
    my ($class, @evaluator_to_frequency) = @_;

    my $self = $class->SUPER::new();

    $self->evaluator_to_frequency(\@evaluator_to_frequency);

    return $self;
}

sub evaluate {
    my ($self, $osero, $color) = @_;

    my $evaluate_sum = 0;

    my $it = natatime 2, @{$self->evaluator_to_frequency()};
    while( my ($evaluator, $frequency) = $it->() ) {
        $evaluate_sum += $evaluator->evaluate($osero, $color) * $frequency;
    }

    return $evaluate_sum;
};

1;
