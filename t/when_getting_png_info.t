# -*- perl -*-

# t/when_getting_png_info.t - test getting various information about the png being converted 

use strict;
use warnings;

use lib "t/lib";

use Test::More;

use Test::PNG;

use Lego::From::PNG;

# ----------------------------------------------------------------------

my $tests = 0;

should_return_correct_width();

should_return_correct_height();

done_testing( $tests );

exit;

# ----------------------------------------------------------------------

sub should_return_correct_width {
   my $size = 15;

   my $png = Test::PNG->new({ width => $size, height => $size, unit_size => $size });

   my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $size });

   cmp_ok($object->png_info->{'width'}, '==', $size, 'should return correct width');

   $tests++;
}

sub should_return_correct_height {
   my $size = 10;

   my $png = Test::PNG->new({ width => $size, height => $size, unit_size => $size });

   my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $size });

   cmp_ok($object->png_info->{'height'}, '==', $size, 'should return correct height');

   $tests++;
}
