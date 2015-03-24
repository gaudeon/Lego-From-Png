# -*- perl -*-

# t/when_tallying_blocks.t - Test module's block_tally method

use strict;
use warnings;

use lib "t/lib";

use Test::More;

use Test::PNG;

use Lego::From::PNG;

# ----------------------------------------------------------------------

my $tests = 0;

should_return_empty_list_with_no_params();

should_return_the_right_count_of_blocks_of_colors();

should_return_lego_colors_approximated_from_a_list_containing_blocks_of_colors();

done_testing( $tests );

exit;

# ----------------------------------------------------------------------

sub should_return_empty_list_with_no_params {
    my $object = Lego::From::PNG->new();

    my @result = $object->block_tally();

    is_deeply(\@result, [ ], "Empty list returned");

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

