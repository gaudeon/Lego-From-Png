# -*- perl -*-

# t/when_loading.t - check module loading and create testing directory

use strict;
use warnings;

use Test::More;

# ----------------------------------------------------------------------

my $tests = 0;

should_use_module();

should_require_module();

should_be_the_module_we_asked_for();

done_testing( $tests );

exit;

# ----------------------------------------------------------------------

sub should_use_module {
   use_ok( 'Lego::From::PNG' );

   $tests++;
}

sub should_require_module {
   require_ok( 'Lego::From::PNG' );

   $tests++;
}

sub should_be_the_module_we_asked_for {
    my $object = Lego::From::PNG->new();
    isa_ok ($object, 'Lego::From::PNG');

   $tests++;
}

