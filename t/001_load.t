# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Lego::From::PNG' ); }

my $object = Lego::From::PNG->new ();
isa_ok ($object, 'Lego::From::PNG');


