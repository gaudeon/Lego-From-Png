

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Lego::From::PNG',
    VERSION_FROM => 'lib/Lego/From/PNG.pm', # finds \$VERSION
    AUTHOR       => 'Travis Chase (gaudeon@cpan.org)',
    ABSTRACT     => 'Convert PNGs into plans to build a two dimensional lego replica. ',
    PREREQ_PM    => {
                        'Test::Simple'       => 0.44,
                        'File::Temp'         => 0.2304,
                        'Image::PNG::Libpng' => 0.39,
                    },
);
