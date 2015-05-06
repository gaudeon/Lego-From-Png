# -*- perl -*-

# t/003_when_loading_brick_information.t - test loading lego brick information

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

should_load_color_const_information_as_a_hash();

should_load_all_color_constants();

should_load_all_brick_dimensions();

done_testing( $tests );

exit;

# ----------------------------------------------------------------------

sub should_load_color_const_information_as_a_hash {
   my $object = Lego::From::PNG->new();

   cmp_ok(ref($object->lego_colors), 'eq', 'HASH', 'should load color const information as a hash');

   $tests++;
}

sub should_load_all_color_constants {
   my $object = Lego::From::PNG->new();

   my $expected_colors = [ sort ( Lego::From::PNG::Const->LEGO_COLORS ) ];

   my $colors = [ sort keys %{ $object->lego_colors } ];

   is_deeply($colors, $expected_colors, 'should load all color constants');

   $tests++;
}

sub should_load_all_brick_dimensions {
    my $object = Lego::From::PNG->new();

    my $expected_lengths = [ sort ( Lego::From::PNG::Const->LEGO_BRICK_LENGTHS ) ];

    my %seen;
    $seen{ $_->length } = 1 for values %{ $object->lego_bricks };

    my $lengths = [ sort keys %seen ];

    is_deeply($lengths, $expected_lengths, 'should load all brick lengths');

    $tests++;
}
