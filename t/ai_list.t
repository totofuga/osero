use strict;
use warnings;
use Test::More;
use Test::MockObject;

BEGIN {
    use_ok('Game::Osero::AIList');
}

my $evaluate1 = Test::MockObject->new();
$evaluate1->set_always('evaluate', 2);

my $evaluate2 = Test::MockObject->new();
$evaluate2->set_always('evaluate', 4);

my $ai_list = new_ok('Game::Osero::AIList', [
        $evaluate1 => 1,
        $evaluate2 => -2,
    ]);

is($ai_list->evaluate(), -6);

done_testing;
