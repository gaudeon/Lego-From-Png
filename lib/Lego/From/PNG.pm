package Lego::From::PNG;

use strict;
use warnings;

use Image::PNG::Libpng qw(:all);
use Image::PNG::Const qw(:all);

use Lego::From::PNG::Const qw(:all);

use Data::Debug;

sub new {
    my $class = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    my $hash = {};

    $hash->{'filename'} = $args{'filename'};

    $hash->{'unit_size'} = $args{'unit_size'} || 8;

    my $self = bless ($hash, ref ($class) || $class);

    return $self;
}

sub lego_colors {
    my $self = shift;

    return $self->{'lego_colors'} ||= do {
        my $hash = {};

        for my $color ( LEGO_COLORS ) {
            my ($cn_key, $hex_key, $r_key, $b_key, $g_key) = (
                $color . '_COMMON_NAME',
                $color . '_HEX_COLOR',
                $color . '_RGB_COLOR_RED',
                $color . '_RGB_COLOR_GREEN',
                $color . '_RGB_COLOR_BLUE',
            );

            no strict 'refs';

            $hash->{ $color } = {
                'common_name' => Lego::From::PNG::Const->$cn_key,
                'hex_color'   => Lego::From::PNG::Const->$hex_key,
                'rgb_color'   => [
                    Lego::From::PNG::Const->$r_key,
                    Lego::From::PNG::Const->$g_key,
                    Lego::From::PNG::Const->$b_key,
                ],
            };
        }

        $hash;
    };
}

sub png {
    my $self = shift;

    return $self->{'png'} ||= do {
        my $png = read_png_file($self->{'filename'}, transforms => PNG_TRANSFORM_STRIP_ALPHA);

        $png;
    };
};

sub png_info {
    my $self = shift;

    return $self->{'png_info'} ||= $self->png->get_IHDR;
}

sub block_tally {
    my $self = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    return () unless $self->{'filename'}; # No file, no blocks

    my @blocks = $self->_png_blocks_of_color;

    return ();
}

sub _png_blocks_of_color {
    my $self = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    my @blocks;

    return @blocks unless $self->{'filename'}; # No file, no blocks

    my $pixel_bytecount = 3;

    my $y = -1;

    for my $row(@{$self->png->get_rows}) {
        $y++;
        next unless ($y % $self->{'unit_size'}) == 0;

        my @values = unpack 'C*', $row;

        my $row_width = (scalar(@values) / $pixel_bytecount) / $self->{'unit_size'};

        for(my $p = 0; $p < $row_width; $p++) {
            my ( $r, $g, $b ) = (
                $values[ ($self->{'unit_size'} * $pixel_bytecount * $p) ],
                $values[ ($self->{'unit_size'} * $pixel_bytecount * $p) + 1 ],
                $values[ ($self->{'unit_size'} * $pixel_bytecount * $p) + 2 ]
            );

            $blocks[$y / $self->{'unit_size'}][$p] = {
                r => $r,
                g => $g,
                b => $b,
            };
        }
    }

    return @blocks;
}

=pod

=head1 NAME

Lego::From::PNG - Convert PNGs into plans to build a two dimensional lego replica.

=head1 SYNOPSIS

  use Lego::From::PNG;

  my $object = Lego::From::PNG;

  $object->block_tally();

=head1 DESCRIPTION

Convert a PNG into a block list and plans to build a two dimensional replica of the PNG.

=head1 USAGE

=head2 lego_colors

 Usage     : ->lego_colors()
 Purpose   : Returns lego color constants consolidated as a hash.

 Returns   : Hash ref with color constants keyed by the official color name in key form.
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=cut


=head2 png

 Usage     : ->png()
 Purpose   : Returns Image::PNG::Libpng object.

 Returns   : Returns Image::PNG::Libpng object. See L<Image::PNG::Libpng> for more details.
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=cut


=head2 png_info

 Usage     : ->png_info()
 Purpose   : Returns png IHDR info from the Image::PNG::Libpng object

 Returns   : A hash of values containing information abou the png such as width and height. See get_IHDR in L<Image::PNG::Libpng> for more details.
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=cut


=head2 block_tally

 Usage     : ->block_tally()
 Purpose   : Convert a provided PNG into a list of lego blocks that will allow building of a two dimensional lego replica.

 Returns   : A list of hashes each containing information about a particular lego block such quantity, dimension and color.
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=cut

=head2 _png_blocks_of_color

 Usage     : ->_png_blocks_of_color()
 Purpose   : Convert a provided PNG into a list of rgb values based on [row][color]. Size of blocks are determined by 'unit_size'

 Returns   : A list of array refs (ie a two-dimensional array) of hashs contain r, g and b keys
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=cut



=head1 BUGS

=head1 SUPPORT

=head1 AUTHOR

    Travis Chase
    CPAN ID: GAUDEON
    gaudeon@cpan.org
    https://github.com/gaudeon/Lego-From-Png

=head1 COPYRIGHT

This program is free software licensed under the...

    The MIT License

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

perl(1).

=cut

1;

