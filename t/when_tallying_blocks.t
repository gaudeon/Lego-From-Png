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

    my $png = Test::PNG->new({ width => $width, height => $height, unit_size => $unit_size, preserve => 1 });

    my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $unit_size });

    my @result = $object->_png_blocks_of_color();

    my $num_blocks_returned = 0;
    $num_blocks_returned += scalar(@$_) for @result;

    cmp_ok($num_blocks_returned, '==', $num_blocks, 'block count should be correct');

    $tests++;
}

