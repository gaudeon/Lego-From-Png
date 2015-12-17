# -*- perl -*-

# t/005_when_getting_png_info.t - test getting various information about the png being converted

use strict;
use warnings;

use lib "t/lib";

use Test::More;

use Test::PNG;

use Lego::From::PNG;

use Lego::From::PNG::Const qw(:all);

# ----------------------------------------------------------------------

my $tests = 0;

should_return_correct_width();

should_return_correct_height();

should_return_correct_block_row_length();

should_return_correct_block_row_height();

should_return_correct_max_brick_length();

should_return_correct_max_brick_depth();

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

sub should_return_correct_block_row_length {
   my ($width, $height, $unit_size) = ( 1024, 16, 16 );

   my $png = Test::PNG->new({ width => $width, height => $height, unit_size => $unit_size });

   my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $unit_size });

   cmp_ok($object->block_row_length, '==', $width / $unit_size, 'should return correct block row width');

   $tests++;
}

sub should_return_correct_block_row_height {
   my ($width, $height, $unit_size) = ( 1024, 16, 16 );

   my $png = Test::PNG->new({ width => $width, height => $height, unit_size => $unit_size });

   my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $unit_size });

   cmp_ok($object->block_row_height, '==', $height / $unit_size, 'should return correct block row height');

   $tests++;
}

sub should_return_correct_max_brick_length {
   my ($width, $height, $unit_size) = ( 1024, 16, 16 );

   my $png = Test::PNG->new({ width => $width, height => $height, unit_size => $unit_size });

   my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $unit_size });

   my $max_length = 0;

   $max_length = $_ for sort { $a <=> $b } LEGO_BRICK_LENGTHS;

   cmp_ok($object->max_lego_brick_length, '==', $max_length, "should return correct max brick length");

   $tests++;
}

sub should_return_correct_max_brick_depth {
   my ($width, $height, $unit_size) = ( 1024, 16, 16 );

   my $png = Test::PNG->new({ width => $width, height => $height, unit_size => $unit_size });

   my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $unit_size });

   my $max_depth = 0;

   $max_depth = $_ for sort { $a <=> $b } LEGO_BRICK_DEPTHS;

   cmp_ok($object->max_lego_brick_depth, '==', $max_depth, "should return correct max brick depth");

   $tests++;
}