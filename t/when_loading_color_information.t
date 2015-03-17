# -*- perl -*-

# t/when_loading_color_information.t - test loading lego color information

use strict;
use warnings;

use lib "t/lib";

use Test::More;

use Test::PNG;

use Lego::From::PNG;

use Lego::From::PNG::Const qw(:all);

# ----------------------------------------------------------------------

my $tests = 0;

should_load_color_const_information_as_a_hash();

should_load_all_color_constants();

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
