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
                'cid'          => $color,
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

sub block_row_width {
    my $self = shift;

    return $self->{'block_row_width'} ||= $self->png_info->{'width'} / $self->{'unit_size'};
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

    for my $pixel_row(@{$self->png->get_rows}) {
        $y++;
        next unless ($y % $self->{'unit_size'}) == 0;

        my $row = $y / $self->{'unit_size'}; # get actual row of blocks we are current on

        my @values = unpack 'C*', $pixel_row;

        my $row_width = (scalar(@values) / $pixel_bytecount) / $self->{'unit_size'};

        for(my $col = 0; $col < $row_width; $col++) {
            my ( $r, $g, $b ) = (
                $values[ ($self->{'unit_size'} * $pixel_bytecount * $col) ],
                $values[ ($self->{'unit_size'} * $pixel_bytecount * $col) + 1 ],
                $values[ ($self->{'unit_size'} * $pixel_bytecount * $col) + 2 ]
            );

            $blocks[ ($row * $row_width) + $col ] = {
                r => $r,
                g => $g,
                b => $b,
            };
        }
    }

    return @blocks;
}

sub _approximate_lego_colors {
    my $self = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    die 'blocks not valid' unless $args{'blocks'} && ref($args{'blocks'}) eq 'ARRAY';

    my @colors;

    for my $block( @{ $args{'blocks'} } ) {
        my @optimal_color =
                map  { $_->{ 'cid' } }
                sort { $a->{ 'score' } <=> $b->{ 'score' } }
                map  {
                    +{
                        cid => $_->{ 'cid' },
                        score => abs($block->{ 'r' } - $_->{ 'rgb_color' }[0]
                               + $block->{ 'g' } - $_->{ 'rgb_color' }[1]
                               + $block->{ 'b' } - $_->{ 'rgb_color' }[2]),
                    };
                }
                values %{ $self->lego_colors }
            ;

        push @colors, $optimal_color[0]; # first color in list should be the optimal color for tested block
    }

    return @colors;
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

=head2 png

 Usage     : ->png()
 Purpose   : Returns Image::PNG::Libpng object.

 Returns   : Returns Image::PNG::Libpng object. See L<Image::PNG::Libpng> for more details.
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 png_info

 Usage     : ->png_info()
 Purpose   : Returns png IHDR info from the Image::PNG::Libpng object

 Returns   : A hash of values containing information abou the png such as width and height. See get_IHDR in L<Image::PNG::Libpng> for more details.
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 block_row_width

 Usage     : ->block_row_width()
 Purpose   : Return the width of one row of blocks. Since a block list is a single dimension array this is useful to figure out whict row a block is on.

 Returns   : The length of a row of blocks (image width / unit size)
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 block_tally

 Usage     : ->block_tally()
 Purpose   : Convert a provided PNG into a list of lego blocks that will allow building of a two dimensional lego replica.

 Returns   : A list of hashes each containing information about a particular lego block such quantity, dimension and color.
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 _png_blocks_of_color

 Usage     : ->_png_blocks_of_color()
 Purpose   : Convert a provided PNG into a list of rgb values based on [row][color]. Size of blocks are determined by 'unit_size'

 Returns   : A list of hashes contain r, g and b values. e.g. ( { r => #, g => #, b => # }, { ... }, ... )
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 _approximate_lego_colors

 Usage     : ->_approximate_lego_colors()
 Purpose   : Generate a list of lego colors based on a list of blocks ( array of hashes containing rgb values )

 Returns   : A list of lego color common name keys that can then reference lego color information using L<Lego::From::PNG::lego_colors>
 Argument  :
 Throws    :

 Comment   :
 See Also  :



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

