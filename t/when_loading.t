# -*- perl -*-

# t/when_loading.t - check module loading and create testing directory

use strict;
use warnings;

use Test::More;

# ----------------------------------------------------------------------

my $tests = 0;

should_use_modules();

should_require_modules();

should_be_the_module_we_asked_for();

done_testing( $tests );

exit;

# ----------------------------------------------------------------------

sub should_use_modules {
   use_ok( 'Lego::From::PNG' );
   use_ok( 'Lego::From::PNG::Const' );
   use_ok( 'Lego::From::PNG::View' );
   use_ok( 'Lego::From::PNG::View::JSON' );

   $tests += 4;
}

sub should_require_modules {
   require_ok( 'Lego::From::PNG' );
   require_ok( 'Lego::From::PNG::Const' );
   require_ok( 'Lego::From::PNG::View' );
   require_ok( 'Lego::From::PNG::View::JSON' );

   $tests += 4;
}

sub should_be_the_module_we_asked_for {
    my $object = Lego::From::PNG->new();
    isa_ok ($object, 'Lego::From::PNG');

   $tests++;
}

