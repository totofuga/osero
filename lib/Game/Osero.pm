package Game::Osero;

use 5.006;
use strict;
use warnings FATAL => 'all';

use base qw(Class::Accessor::Fast);

use constant {
    BLANK => 0,
    WHITE => 1,
    BLACK => 2,
};

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors(qw{ board turn openrate });


=head1 NAME

Game::Osero - The great new Game::Osero!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

オセロクラス

=head2 new

インスタンス生成

=cut

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->initialize();

    return $self;
}

=head2 get_can_drop_pos

置けるところを配列で取得する

=cut 
sub get_can_drop_pos {
    my ($self) = @_;

    # まずすべてをブランク設定
    my @can_drop_pos;
    foreach my $x ( 0..7 ) {
        foreach my $y ( 0..7 ) {
            push @can_drop_pos, [$x, $y] if $self->can_drop($x, $y);
        }
    }

    return \@can_drop_pos;
}

=head2 initialize

オセロ版を初期化する

=cut
sub initialize {
    my ($self) = @_;

    # まずすべてをブランク設定
    my $board = [];
    my $openrate_board = [];
    foreach my $x ( 0..7 ) {
        foreach my $y ( 0..7 ) {
            $board->[$x][$y] =0; 
        }
    }

    # 初期駒配置
    $board->[3][3] = $board->[4][4] = WHITE; 
    $board->[3][4] = $board->[4][3] = BLACK; 

    $self->set_board($board);

    #openrateの初期化
    my $openrate = [];
    foreach my $x ( 0..7 ) {

        foreach my $y ( 0..7 ) {

            $openrate->[$x][$y] = 8;

            if ( $x == 0 || $x ==7 ) {
                $openrate->[$x][$y] = 5;
            } 
            
            if ( $y == 0 || $y == 7 ) {
                if ( $openrate->[$x][$y] == 5 ) {
                    $openrate->[$x][$y] = 3;
                } else {
                    $openrate->[$x][$y] = 5;
                }
            }
        }
    }

    $self->set_openrate($openrate);

    # 初期配置の開放度設定
    $self->drop_openrate(3, 3);
    $self->drop_openrate(4, 3);
    $self->drop_openrate(3, 4);
    $self->drop_openrate(4, 4);

    # 手番を黒に設定
    $self->set_turn(BLACK);

}

=head2 get_rival_turn

相手の駒の色

=cut
sub get_rival_turn {
    my ($self) = @_;

    return $self->get_turn == BLACK ? WHITE : BLACK;
}


=head2 drop

駒を置く

=cut
sub drop {
    my ($self, $x, $y) = @_;

    return 0 unless $self->can_drop($x, $y);

    # 駒を返す
    $self->reverse($x, $y);

    # 駒を置く
    $self->get_board()->[$x][$y] = $self->get_turn();

    # 開放度更新
    $self->drop_openrate($x, $y);

    return 1;
}

=head2 can_drop

その位置に駒を置けるか確認

=cut
sub can_drop {
    my ($self, $x, $y) = @_;

    if ( @_ == 1 ) {
        foreach $x ( 0..7 ) {
            foreach $y ( 0..7 ) {
                return 1 if $self->can_drop($x, $y);
            }
        }
        return 0;
    }

    # 有効性とblank確認
    return 0 unless $self->_is_available_pos($x, $y);
    return 0 unless $self->get_board->[$x][$y] == BLANK;

    # ８方向に相手の駒が変わるか確認
    return 1 if $self->_can_drop_vec($x, $y, -1, -1); # 左上 
    return 1 if $self->_can_drop_vec($x, $y,  0, -1); # 上 
    return 1 if $self->_can_drop_vec($x, $y,  1, -1); # 右上
    return 1 if $self->_can_drop_vec($x, $y, -1,  0); # 左
    return 1 if $self->_can_drop_vec($x, $y,  1,  0); # 右
    return 1 if $self->_can_drop_vec($x, $y, -1,  1); # 左下
    return 1 if $self->_can_drop_vec($x, $y,  0,  1); # 下
    return 1 if $self->_can_drop_vec($x, $y,  1,  1); # 右下

    # どこも変わらなければ無効
    return 0;
}

=head2 reverse

駒を置いた位置から八方向にひっくり返せる駒をひっくり返す

=cut 
sub reverse {
    my ($self, $x, $y) = @_;

    # ひっくり返せるところをひっくり返す
    $self->_reverse_vec($x, $y, -1, -1) if $self->_can_drop_vec($x, $y, -1, -1); # 左上 
    $self->_reverse_vec($x, $y,  0, -1) if $self->_can_drop_vec($x, $y,  0, -1); # 上 
    $self->_reverse_vec($x, $y,  1, -1) if $self->_can_drop_vec($x, $y,  1, -1); # 右上
    $self->_reverse_vec($x, $y, -1,  0) if $self->_can_drop_vec($x, $y, -1,  0); # 左
    $self->_reverse_vec($x, $y,  1,  0) if $self->_can_drop_vec($x, $y,  1,  0); # 右
    $self->_reverse_vec($x, $y, -1,  1) if $self->_can_drop_vec($x, $y, -1,  1); # 左下
    $self->_reverse_vec($x, $y,  0,  1) if $self->_can_drop_vec($x, $y,  0,  1); # 下
    $self->_reverse_vec($x, $y,  1,  1) if $self->_can_drop_vec($x, $y,  1,  1); # 右下
}

=head2 is_end

終了判定

=cut 
sub is_end {
    my ($self) = @_;

    my $has_color = {
        +BLANK => 0,
        +BLACK => 0,
        +WHITE => 0,
    };
    foreach my $x ( 0..7 ) {
        foreach my $y (0..7) {
            $has_color->{ $self->get_board()->[$x][$y] } = 1;
        }
    }

    return !$has_color->{+BLANK} ||
           !$has_color->{+BLACK} || 
           !$has_color->{+WHITE};
}

=head2 reverse

指定した方向の駒をひっくり返す

=cut 
sub _reverse_vec {
    my ($self, $x, $y, $dx, $dy) = @_;

    my $tx = $x;
    my $ty = $y;

    while (1) {
        $tx += $dx;
        $ty += $dy;

        # 相手の駒じゃなければそこで終了
        last unless $self->get_board()->[$tx][$ty] == $self->get_rival_turn;
            
        $self->get_board()->[$tx][$ty] = $self->get_turn;
    }
}

=head2 _can_drop_vec

指定した方向に対して駒を置けるか調べる

=cut
sub _can_drop_vec {
    my ($self, $x, $y, $dx, $dy) = @_;

    my $tx = $x;
    my $ty = $y;

    # 有効性確認
    return 0 unless $self->_is_available_pos($tx, $ty);
    # 置く位置はBLANKで無ければいけない
    return 0 unless $self->get_board()->[$tx][$ty] == BLANK;

    # 一つ先の位置
    $tx += $dx;
    $ty += $dy;

    # 有効性確認
    return 0 unless $self->_is_available_pos($tx, $ty);
    # 一つ先は相手の駒
    return 0 unless $self->get_board()->[$tx][$ty] == $self->get_rival_turn();

    while (1) {
        $tx += $dx;
        $ty += $dy;

        # 有効性確認
        return 0 unless $self->_is_available_pos($tx, $ty);

        # 相手の駒だった場合はもう一つ先をみる
        next if $self->get_board()->[$tx][$ty] == $self->get_rival_turn();

        # 自分の駒で挟んでいる場合は有効
        return 1 if $self->get_board()->[$tx][$ty] == $self->get_turn();

        # それ以外は無効
        return 0;
    }
}

=head2 _is_available_pos

指定された座標が盤内かを調べる

=cut
sub _is_available_pos {
    my ($self, $x, $y) = @_;

    return $x >= 0 && $y >= 0 && $x < 8 && $y < 8;
}

=head2 drop_openrate

開放度更新

=cut
sub drop_openrate {
    my ($self, $x, $y) = @_;

    -- $self->get_openrate->[$x - 1][$y - 1] if $self->_is_available_pos($x - 1, $y - 1);
    -- $self->get_openrate->[$x    ][$y - 1] if $self->_is_available_pos($x    , $y - 1);
    -- $self->get_openrate->[$x - 1][$y    ] if $self->_is_available_pos($x - 1, $y    );
    -- $self->get_openrate->[$x + 1][$y + 1] if $self->_is_available_pos($x + 1, $y + 1);
    -- $self->get_openrate->[$x    ][$y + 1] if $self->_is_available_pos($x    , $y + 1);
    -- $self->get_openrate->[$x + 1][$y    ] if $self->_is_available_pos($x + 1, $y    );
    -- $self->get_openrate->[$x - 1][$y + 1] if $self->_is_available_pos($x - 1, $y + 1);
    -- $self->get_openrate->[$x + 1][$y - 1] if $self->_is_available_pos($x + 1, $y - 1);
}

=head1 AUTHOR

fujita.yoshihiko, C<< <fujita.yoshihiko at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-osero at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=osero>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Game::Osero


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=osero>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/osero>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/osero>

=item * Search CPAN

L<http://search.cpan.org/dist/osero/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 藤田善光.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Game::Osero
