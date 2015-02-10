# -*- perl -*-

# t/002_block_tally.t - Test module's block_tally method

use Test::More tests => 1;

use Lego::From::PNG;

my $object = Lego::From::PNG->new();

my @result = $object->block_tally();

is_deeply(\@result, [ ], "No results returned yet");

my $png = Test::PNG->new();

#print $png->{'filename'};

package Test::PNG;

use File::Temp qw(tempfile);
use Image::PNG::Libpng qw(create_write_struct);

sub new {
    my $class = shift;
    my $args  = ref $_[0] eq 'HASH' ? shift : {};

    my $self = bless $args, $class;

    ($self->{'fh'}, $self->{'filename'}) = tempfile( 'testpngXXXXXX', SUFFIX => '.png', TMPDIR => 1);
    binmode $self->{'fh'};

    $self->{'width'}  ||= 1024;
    $self->{'height'} ||= 768;

    $self->generate_rnd_png;

    return $self;
}

sub generate_rnd_png {
    my $self = shift;

    my $rndclr = sub { srand time + (shift || 0); int (rand () * 0x100); };

    my $png = create_write_struct();

    $png->init_io($self->{'fh'});

    $png->set_IHDR ({height => $self->{'height'}, width => $self->{'width'}, bit_depth => 8,
                     color_type => PNG_COLOR_TYPE_RGB});

    my @rows;
    # TODO - figure out how to make the image color instead of just being greyscale...
    for(my $h = 0; $h < $self->{'height'}; $h++) {
        my @row;
        for(my $w = 0; $w < $self->{'width'}; $w++) {
            push @row, $rndclr->($h + $w * 3000), $rndclr->($h + $w * 10), $rndclr->($h + $w * 200);
        }
        my $len = $self->{'width'} * 3;
        push @rows, pack("C[$len]", @row);
    }

    $png->set_rows(\@rows);

    $png->write_png();
}

sub DESTROY {
    my $self = shift;

    # Debug - comment this when you want to see the temp image after the test if over
    unlink $self->{'filename'};
}

1;
