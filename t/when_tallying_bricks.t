# -*- perl -*-

# t/when_tallying_bricks.t - Test module's brick_tally method

use strict;
use warnings;

use lib "t/lib";

use Test::More;

use Test::PNG;

use Lego::From::PNG;

use Lego::From::PNG::Const qw(:all);

use Data::Debug;

# ----------------------------------------------------------------------

my $tests = 0;

should_return_empty_list_with_no_params();

should_return_the_right_count_of_blocks_of_colors();

should_return_lego_colors_approximated_from_a_list_containing_blocks_of_colors();

should_return_a_list_of_lego_bricks_per_row_of_png();

done_testing( $tests );

exit;

# ----------------------------------------------------------------------

sub should_return_empty_list_with_no_params {
    my $object = Lego::From::PNG->new();

    my $result = $object->brick_tally();

    is_deeply($result, { bricks => {}, plan => [] }, "Empty list returned");

    $tests++;
}

sub should_return_the_right_count_of_blocks_of_colors {
    my ($width, $height, $unit_size) = (1024, 768, 16);
    my $num_blocks = ($width / $unit_size) * ($height / $unit_size);

    my $png = Test::PNG->new({ width => $width, height => $height, unit_size => $unit_size });

    my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $unit_size });

    my @result = $object->_png_blocks_of_color();

    cmp_ok(scalar(@result), '==', $num_blocks, 'block count should be correct');

    $tests++;
}

sub should_return_lego_colors_approximated_from_a_list_containing_blocks_of_colors {
    my ($width, $height, $unit_size) = (32, 32, 16);

    my $png = Test::PNG->new({ width => $width, height => $height, unit_size => $unit_size });

    my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $unit_size });

    my @blocks = $object->_png_blocks_of_color();

    my @result = $object->_approximate_lego_colors(blocks => \@blocks);

    cmp_ok(scalar(@result), '==', scalar(@blocks), 'approximate color count and block count are the same');

    $tests++;

    # Generate each lego color as a test block and it should approximate back to that same color
    # Note: Dark red and green are so close that they can be either...
    my @test_blocks = map {
        +{
            r   => $_->{ 'rgb_color' }[0],
            g   => $_->{ 'rgb_color' }[1],
            b   => $_->{ 'rgb_color' }[2],
            cid => $_->{ 'cid' } =~ m/^ ( DARK_GREEN | DARK_RED ) $/x ? 'DARK_GREEN_OR_DARK_RED' : $_->{ 'cid' },
        }
    } values %{ $object->lego_colors };

    @result = $object->_approximate_lego_colors(blocks => \@test_blocks);

    @result = map { $_ =~ m/^ ( DARK_GREEN | DARK_RED ) $/x ? 'DARK_GREEN_OR_DARK_RED' : $_ } @result;

    for(my $i = 0; $i < scalar( @test_blocks ); $i++) {
        my $cid = $test_blocks[$i]{'cid'};
        cmp_ok($result[$i], 'eq', $cid, "$cid approximated correctly");
        $tests++;
    }
}

sub should_return_a_list_of_lego_bricks_per_row_of_png {
    my ($brick_width, $max_brick_width, $unit_size) = (1, 8, 16);

    for( $brick_width .. $max_brick_width) {
        my ($width, $height) = ($brick_width * $unit_size, $unit_size);

        # Pick a random lego color to test this part
        my $color = do {
            my @color_list = LEGO_COLORS;
            my $num_lego_colors = scalar( @color_list );
            $color_list[ int(rand() * $num_lego_colors) ];
        };
        my $color_rgb = do {
            my ($r, $g, $b) = ($color . '_RGB_COLOR_RED', $color . '_RGB_COLOR_GREEN', $color . '_RGB_COLOR_BLUE');
            [ Lego::From::PNG::Const->$r, Lego::From::PNG::Const->$g, Lego::From::PNG::Const->$b ];
        };

        my $png = Test::PNG->new({ width => $width, height => $height, unit_size => $unit_size, color => $color_rgb });

        my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $unit_size });

        my @blocks = $object->_png_blocks_of_color();

        my $num_block_colors = do {
            my %colors;
            $colors{ join('_', $_->{'r'}, $_->{'g'}, $_->{'b'}) } = 1 for @blocks;
            scalar(keys %colors);
        };

        cmp_ok($num_block_colors, '==', 1, 'Only one color was used to generate blocks');
        $tests++;

        is_deeply($blocks[0], {
            r => $object->lego_colors->{ $color }->{'rgb_color'}->[0],
            g => $object->lego_colors->{ $color }->{'rgb_color'}->[1],
            b => $object->lego_colors->{ $color }->{'rgb_color'}->[2],
        }, 'The color we randomly chose is being used');
        $tests++;

        my @units = $object->_approximate_lego_colors(blocks => \@blocks);

        my @bricks = $object->_generate_brick_list(units => \@units);

        is_deeply($bricks[0], {
            width  => $brick_width,
            height => 1,
            color  => $color,
            id     => join('*', $color, $brick_width, 1),
            y      => 0,
        }, 'Brick returned is the correct dimensions and color');
        $tests++;

debug($object->brick_tally());

        $brick_width++; # Increase the brick with to test the next brick size
    }
}
