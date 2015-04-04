# -*- perl -*-

# t/when_documenting_modules.t - Test module's pod coverage

use strict;
use warnings;

use Test::More;

# ----------------------------------------------------------------------

my $tests = 0;

should_have_good_pod_coverage();

done_testing( $tests );

exit;

# ----------------------------------------------------------------------

sub should_have_good_pod_coverage {
    eval "use Test::Pod::Coverage";

    SKIP: {
        $tests += 2;

        skip "Test::Pod::Coverage required for testing pod coverage", 1 if $@;
        pod_coverage_ok( "Lego::From::PNG");
        pod_coverage_ok( "Lego::From::PNG::Const");
    }
}
