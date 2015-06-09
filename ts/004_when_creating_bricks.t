# -*- perl -*-

# ts/004_when_creating_bricks.t - test brick module

use lib "t/lib";

use Test::Stream;

use Test::PNG;

use Lego::From::PNG;

use Lego::From::PNG::Brick;

use Lego::From::PNG::Const qw(:all);

# ----------------------------------------------------------------------

should_die_if_invalid_color();

should_set_default_dimensions();

should_be_able_to_access_color();

should_be_able_to_set_color();

should_be_able_to_access_dimensions();

should_be_able_to_set_dimensions();

should_be_able_to_access_meta();

should_be_able_to_access_color_information();

done_testing();

exit;

# ----------------------------------------------------------------------

sub should_die_if_invalid_color {
    undef $@;
    my $brick = eval { Lego::From::PNG::Brick->new(color => 'NOTACOLOR') };

    my $has_error = defined $@ ? 1 : 0;
    cmp_ok($has_error, "==", 1, "Exception in ->new if setting invalid color");

    $brick = Lego::From::PNG::Brick->new(color => 'BLACK');

    undef $@;
    eval { $brick->color('NOTACOLOR') };

    $has_error = defined $@ ? 1 : 0;
    cmp_ok($has_error, "==", 1, "Exception in ->color if setting invalid color");
}

sub should_set_default_dimensions {
    my $brick = Lego::From::PNG::Brick->new(color => 'BLACK');

    my $dimensions = {};
    @{$dimensions}{qw(depth length height)} = @{$brick}{qw(depth length height)};

    my $expected_dimensions = {
        depth  => 1,
        length => 1,
        height => 1,
    };

    mostly_like($dimensions, $expected_dimensions, "Default dimensions are set");
}

sub should_be_able_to_access_color {
    my $brick = Lego::From::PNG::Brick->new(color => 'BLACK');

    cmp_ok($brick->color, 'eq', 'BLACK', "Accessed color");
}

sub should_be_able_to_set_color {
    my $brick = Lego::From::PNG::Brick->new(color => 'BLACK');

    $brick->color('WHITE');

    cmp_ok($brick->color, 'eq', 'WHITE', "Set color");
}

sub should_be_able_to_access_dimensions {
    my $brick = Lego::From::PNG::Brick->new(color => 'BLACK', depth => 1, length => 2, height => 3);

    cmp_ok($brick->depth, '==', 1, "Accessed depth");

    cmp_ok($brick->length, '==', 2, "Accessed length");

    cmp_ok($brick->height, '==', 3, "Accessed height");
}

sub should_be_able_to_set_dimensions {
    my $brick = Lego::From::PNG::Brick->new(color => 'BLACK');

    cmp_ok($brick->depth(5), '==', 5, "Set depth");

    cmp_ok($brick->length(6), '==', 6, "Set length");

    cmp_ok($brick->height(7), '==', 7, "Set height");
}


sub should_be_able_to_access_meta {
    my $brick = Lego::From::PNG::Brick->new(color => 'BLACK', meta => {
        id    => 1,
        ara   => [],
        stuff => {},
    });

    my $expected = {
        id    => 1,
        ara   => [],
        stuff => {},
    };

    mostly_like($brick->meta, $expected, "Meta accessed");
}

sub should_be_able_to_access_color_information {
    my $png = Lego::From::PNG->new();
    my $brick = Lego::From::PNG::Brick->new(color => 'BLACK');

    mostly_like($brick->color_info ,$png->lego_colors->{'BLACK'}, "Correct color information is returned");
}
