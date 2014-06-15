package Game::Osero::UI::Web;
use strict;
use warnings;
use Plack;
use Game::Osero;
use Game::Osero::AIList;
use Data::Dumper;
use Plack::Request;
use Game::Osero::AI::Edge;
use Game::Osero::AI::Openrate;
use Game::Osero::AI::Fixed;
use Game::Osero::AI::MiniMax;
use Clone qw(clone);

use base qw| Class::Accessor::Fast |;
use Template;

use overload (
    '&{}'     => \&func,
    fallback => 1,
);


__PACKAGE__->mk_accessors(qw| osero template_base edge_ai openrate_ai fixed_ai |);

sub new {
    my ($class) = @_;

    my $self = $class->SUPER::new();

    $self->osero(Game::Osero->new());
    $self->template_base(do {local $/; <DATA>});

    $self->edge_ai(Game::Osero::AI::Edge->new());
    $self->openrate_ai(Game::Osero::AI::Openrate->new());
    $self->fixed_ai(Game::Osero::AI::Fixed->new());

    return $self;
}


sub func {
    my ($self) = @_;



    return sub { 
        my $env = shift;
        my $req = Plack::Request->new($env);

        my $x = $req->param('x');
        my $y = $req->param('y');
        if ( defined $x && defined $y ) { 
            $self->osero->drop($x, $y);
            $self->osero->set_turn($self->osero->get_rival_turn);

            $self->drop_com;
        }

        print Dumper($x, $y);
        [200, [ 'Content-Type' => 'text/html' ], [$self->get_html()] ] 
    };    
}

sub drop_com {
    my ($self) = @_;
    my $osero = $self->osero;

    my $can_drop_pos = $osero->get_can_drop_pos;

    if ( @$can_drop_pos ) {
        my $edge_ai     = $self->edge_ai();
        my $openrate_ai = $self->openrate_ai();
        my $fixed_ai    = $self->fixed_ai();

        my $evaluator = Game::Osero::AIList->new(
            $edge_ai     => 100,
            $openrate_ai => -10,
            $fixed_ai    => 1,
        );

        my $minmax = Game::Osero::AI::MiniMax->new({
            evaluator => $evaluator,
        });

        my $color = $osero->get_turn;

        my $max_evaluate_value;
        my $max_evaluate_pos;
        foreach my $pos (@$can_drop_pos) {

            my $calc_osero = clone $osero;
            $calc_osero->drop($pos->[0], $pos->[1]);
            $calc_osero->set_turn($calc_osero->get_rival_turn);

            my $evaluate_value = $minmax->min_level(3, $calc_osero, $color);

            if ( !defined $max_evaluate_pos || ( $max_evaluate_value < $evaluate_value )) {
                $max_evaluate_value = $evaluate_value;
                $max_evaluate_pos = $pos;
            }
        }

        $osero->drop($max_evaluate_pos->[0], $max_evaluate_pos->[1]);


    } else {
        #$c->stash->{mess} = "コンピュータはパスしました。\n"
    }

    $osero->set_turn($osero->get_rival_turn);
}

sub get_html {
    my ($self) = @_;

    my $template = Template->new();

    my $data = $self->template_base();

    my $out;
    $template->process(\$data, { osero => $self->osero() }, \$out)
        || die $template->error();


    return $out;
}

1;
__DATA__
<html>
    <body>
        [%- mess %]
        <table border='1'>
        [%- FOREACH line IN osero.get_board %]
        [% xcount = loop.count - 1 %]
            <tr>
            [%- FOREACH cell IN line %]
            [% ycount = loop.count - 1 %]
                <td>
                [%- IF cell == 1 -%]
                    ○
                [%- ELSIF cell == 2 -%]
                    ●
                [%- ELSE -%]
                    [%- IF osero.can_drop(xcount, ycount) -%]
                        <a href="?x=[% xcount %]&y=[% ycount %]">&nbsp;&nbsp;&nbsp;&nbsp;</a>
                    [%- ELSE %]
                        &nbsp;&nbsp;&nbsp;&nbsp;
                    [%- END %]
                [%- END -%]
                </td>
            [%- END %]
            </tr>
        [%- END %]
        <table>
    </body>
</html>
