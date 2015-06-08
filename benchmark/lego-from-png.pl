#!/usr/bin/env perl

Script->new->run;
exit;

package Script;

use strict;
use warnings;

use FindBin;
use lib ("$FindBin::Bin/../lib", "$FindBin::Bin/../t/lib");

use Test::PNG;

use Lego::From::PNG;

use Benchmark qw(:all);
use Data::Debug;

sub new { bless {}, shift }

sub run {
    my $self = shift;

    for my $sub ( $self->subroutines ) {
        $self->$sub if $self->can($sub);
    }
}

sub subroutines { qw(
_find_lego_color
) }

sub _find_lego_color {
    my $self  = shift;
    my $count = 1000;

    my ($width, $height, $unit_size) = (256, 256, 16);

    my $png = Test::PNG->new({ width => $width, height => $height, unit_size => $unit_size });

    my $object = Lego::From::PNG->new({ filename => $png->filename, unit_size => $unit_size });

    my @blocks = $object->_png_blocks_of_color();

    cmpthese($count, {
        '_find_lego_color'      => sub {
            $object->_find_lego_color( $_->{'r'}, $_->{'g'}, $_->{'b'} ) for @blocks;
        },
        '_find_lego_color_fast' => sub {
            $object->_find_lego_color_fast( $_->{'r'}, $_->{'g'}, $_->{'b'} ) for @blocks;
        },
    });
}

1;
