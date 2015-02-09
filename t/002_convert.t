# -*- perl -*-

# t/002_block_tally.t - Test module's block_tally method

use Test::More tests => 1;

use Lego::From::PNG;

my $object = Lego::From::PNG->new();

my @result = $object->block_tally();

is_deeply(\@result, [ ], "No results returned yet");
