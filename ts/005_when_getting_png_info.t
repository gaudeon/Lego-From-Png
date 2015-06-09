# -*- perl -*-

# ts/005_when_getting_png_info.t - test getting various information about the png being converted

use lib "t/lib";

use Test::Stream;

use Test::PNG;

use Lego::From::PNG;

# ----------------------------------------------------------------------

should_return_correct_width();

should_return_correct_height();

should_return_correct_block_row_length();

should_return_correct_block_row_height();

done_testing();

exit;

# ----------------------------------------------------------------------

sub should_return_correct_width {
   my $size = 15;

   my $png = Test::PNG->new({ width => $size, height => $size, unit_size => $size });

   my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $size });

   cmp_ok($object->png_info->{'width'}, '==', $size, 'should return correct width');
}

sub should_return_correct_height {
   my $size = 10;

   my $png = Test::PNG->new({ width => $size, height => $size, unit_size => $size });

   my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $size });

   cmp_ok($object->png_info->{'height'}, '==', $size, 'should return correct height');
}

sub should_return_correct_block_row_length {
   my ($width, $height, $unit_size) = ( 1024, 16, 16 );

   my $png = Test::PNG->new({ width => $width, height => $height, unit_size => $unit_size });

   my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $unit_size });

   cmp_ok($object->block_row_length, '==', $width / $unit_size, 'should return correct block row width');
}

sub should_return_correct_block_row_height {
   my ($width, $height, $unit_size) = ( 1024, 16, 16 );

   my $png = Test::PNG->new({ width => $width, height => $height, unit_size => $unit_size });

   my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $unit_size });

   cmp_ok($object->block_row_height, '==', $height / $unit_size, 'should return correct block row height');
}
