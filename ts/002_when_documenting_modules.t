# -*- perl -*-

# ts/002_when_documenting_modules.t - Test module's pod coverage

use Test::Stream;

# ----------------------------------------------------------------------

should_have_good_pod_coverage();

done_testing();

exit;

# ----------------------------------------------------------------------

sub should_have_good_pod_coverage {
    eval "use Test::Pod::Coverage";

    SKIP: {
        skip "Test::Pod::Coverage required for testing pod coverage", 5 if $@;
        pod_coverage_ok( "Lego::From::PNG");
        pod_coverage_ok( "Lego::From::PNG::Brick");
        pod_coverage_ok( "Lego::From::PNG::Const");
        pod_coverage_ok( "Lego::From::PNG::View");
        pod_coverage_ok( "Lego::From::PNG::View::JSON");
    }
}
