use strict;
use warnings;

use Test::More;
use HTTP::Request::Common;
use Plack::Test;


BEGIN {
    use_ok("Game::Osero::UI::Web");
}

my $web = new_ok("Game::Osero::UI::Web");

test_psgi($web,
    sub {
        my ($cb) = @_;
        my $res = $cb->(GET "/");

        print $res->content;
    }
);

done_testing();
