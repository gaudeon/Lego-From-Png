# -*- perl -*-

# ts/001_load.t - check module loading and create testing directory

use Test::Stream;

# ----------------------------------------------------------------------

should_use_modules();

should_require_modules();

should_be_the_module_we_asked_for();

done_testing();

exit;

# ----------------------------------------------------------------------

sub should_use_modules {
    eval {
        use Lego::From::PNG;
        use Lego::From::PNG::Brick;
        use Lego::From::PNG::Const;
        use Lego::From::PNG::View;
        use Lego::From::PNG::View::JSON;
        use Lego::From::PNG::View::HTML;
    };

    my $msg = 'All modules loaded with use';

    $@ ? fail($msg) : pass($msg);
}

sub should_require_modules {
    eval {
        require Lego::From::PNG;
        require Lego::From::PNG::Brick;
        require Lego::From::PNG::Const;
        require Lego::From::PNG::View;
        require Lego::From::PNG::View::JSON;
        require Lego::From::PNG::View::HTML;
    };

    my $msg = 'All modules loaded with require';

    $@ ? fail($msg) : pass($msg);
}

sub should_be_the_module_we_asked_for {
    my $object = Lego::From::PNG->new();
    isa_ok ($object, 'Lego::From::PNG');
}

