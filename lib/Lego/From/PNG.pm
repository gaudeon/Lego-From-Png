package Lego::From::PNG;

use strict;
use warnings;

use Image::PNG::Libpng qw(:all);
use Image::PNG::Const qw(:all);

use Lego::From::PNG::Const qw(:all);

use Lego::From::PNG::Brick;

use Lego::From::PNG::View::JSON;

use Data::Debug;

sub new {
    my $class = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    my $hash = {};

    $hash->{'filename'} = $args{'filename'};

    $hash->{'unit_size'} = $args{'unit_size'} || 1;

    # Brick depth and height defaults
    $hash->{'brick_depth'} = 1;

    $hash->{'brick_height'} = 1;

    # White list default
    $hash->{'whitelist'} = ($args{'whitelist'} && ref($args{'whitelist'}) eq 'ARRAY' && scalar(@{$args{'whitelist'}}) > 0) ? $args{'whitelist'} : undef;

    # Black list default
    $hash->{'blacklist'} = ($args{'blacklist'} && ref($args{'blacklist'}) eq 'ARRAY' && scalar(@{$args{'blacklist'}}) > 0) ? $args{'blacklist'} : undef;

    my $self = bless ($hash, ref ($class) || $class);

    return $self;
}

sub lego_colors {
    my $self = shift;

    return $self->{'lego_colors'} ||= do {
        my $hash = {};

        for my $color ( LEGO_COLORS ) {
            my ($cn_key, $hex_key, $r_key, $g_key, $b_key) = (
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

sub lego_bricks {
    my $self = shift;

    return $self->{'lego_bricks'} ||= do {
        my $hash = {};

        for my $color ( LEGO_COLORS ) {
            for my $length ( LEGO_BRICK_LENGTHS ) {
                my $brick = Lego::From::PNG::Brick->new( color => $color, length => $length );

                $hash->{ $brick->identifier } = $brick;
            }
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

sub process {
    my $self = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    my $tally = {
        bricks => {},
        plan   => [],
    };

    if($self->{'filename'}) {
        my @blocks = $self->_png_blocks_of_color;

        my @units = $self->_approximate_lego_colors( blocks => \@blocks );

        my @bricks = $self->_generate_brick_list(units => \@units);

        $tally->{'plan'} = [ map { $_->flatten } @bricks ];

        my %list;
        for my $brick(@bricks) {
            if(! exists $list{ $brick->identifier }) {
                $list{ $brick->identifier } = $brick->flatten;

                delete $list{ $brick->identifier }{'meta'}; # No need for meta in brick list

                $list{ $brick->identifier }{'quantity'} = 1;
            }
            else {
                $list{ $brick->identifier }{'quantity'}++;
            }
        }

        $tally->{'bricks'} = \%list;
    }

    if($args{'view'}) {
        my $view   = $args{'view'};
        my $module = "Lego::From::PNG::View::$view";

        $tally = eval {
            (my $file = $module) =~ s|::|/|g;
            require $file . '.pm';

            $module->new->print($tally);
        };

        die "Failed to format as a view ($view). $@" if $@;
    }

    return $tally;
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
                        score => abs($block->{ 'r' } - $_->{ 'rgb_color' }[0])
                               + abs($block->{ 'g' } - $_->{ 'rgb_color' }[1])
                               + abs($block->{ 'b' } - $_->{ 'rgb_color' }[2]),
                    };
                }
                values %{ $self->lego_colors }
            ;

        my ($optimal_color) = grep {
            my $choose_this_color = 1;

            $choose_this_color = 0 if ! $self->color_is_whitelisted( $_ );

            $choose_this_color = 0 if $self->color_is_blacklisted( $_ );

            $choose_this_color; # return result
        } @optimal_color;

        push @colors, $optimal_color; # first color in list that passes whitelist and blacklist should be the optimal color for tested block
    }

    return @colors;
}

sub _generate_brick_list {
    my $self = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    die 'units not valid' unless $args{'units'} && ref($args{'units'}) eq 'ARRAY';

    my @units = @{ $args{'units'} };
    my $row_width = $self->block_row_width;
    my $brick_height = 1; # bricks are only one unit high
    my @brick_list;

    for(my $y = 0; $y < (scalar(@units) / $row_width); $y++) {
        my @row = splice @units, 0, $row_width;

        my $push_color = sub {
           my ($color, $length) = @_;

           if($color) {
                push @brick_list, Lego::From::PNG::Brick->new(
                    color  => $color,
                    depth  => $self->{'brick_depth'},
                    length => $length,
                    height => $self->{'brick_height'},
                    meta   => {
                        y => $y,
                    },
                );
            }
        };

        my $process_color_sample = sub {
            my ($color, $length) = @_;

            return if $length <= 0;

            # Now make sure we find bricks we are allowed to use
            FIND_BRICKS: {
                for( 1 .. $length) { # Only need to loop at least the number of times equal to the length of color found
                    my $valid_length = $length;
                    FIND_VALID_LENGTH: {
                        for(;$valid_length > 0;$valid_length--) {
                            my $dim = join('x',$self->{'brick_depth'},$valid_length,$self->{'brick_height'});

                            next FIND_VALID_LENGTH if $self->dimension_is_blacklisted($dim);
                            last FIND_VALID_LENGTH if $self->dimension_is_whitelisted($dim);
                        }
                    }

                    $push_color->($color, $valid_length);
                    $length -= $valid_length;

                    last FIND_BRICKS if $length <= 0; # No need to push more bricks, we found them all
                }
            }

            die "No valid bricks found for remaining units of color" if $length > 0; # Catch if we have gremlins in our whitelist/blacklist
        };

        # Run through rows and process colors
        my $next_brick_color = '';
        my $next_brick_length = 0;

        for my $color(@row) {
            if( $color ne $next_brick_color ) {
                $process_color_sample->($next_brick_color, $next_brick_length);

                $next_brick_color = $color;
                $next_brick_length = 0;
            }

            $next_brick_length++;
        }

        $process_color_sample->($next_brick_color, $next_brick_length); # Process last color found
    }

    return @brick_list;
}

sub whitelist { shift->{'whitelist'} }

sub has_whitelist_with_colors {
    my $self = shift;

    return scalar( grep { /^[a-z]/i } @{ $self->whitelist || [] } );
}

sub has_whitelist_with_dimensions {
    my $self = shift;

    return scalar( grep { /^\d+x\d+x\d+$/i } @{ $self->whitelist || [] } );
}

sub color_is_whitelisted {
    my $self = shift;
    my $cid  = uc(shift);

    return 1 if ! $self->has_whitelist_with_colors; # return true if there is no whitelist, meaning all colors could be whitelisted

    for my $entry( @{ $self->whitelist || [] } ) {
        next unless $entry =~ /^[a-z]/i; # If there is at least a letter at the beginning then this entry has a color we can check

        my ($color) = split('_', $entry); # Entries can be either a color, a block identifier or just block dimensions so just get the color
        $color = uc($color);

        return 1 if $cid eq $color;
    }

    return 0; # Color is not in whitelist
}

sub dimension_is_whitelisted {
    my $self = shift;
    my $dim  = lc(shift);

    return 1 if ! $self->has_whitelist_with_dimensions; # return true if there is no whitelist, meaning all dimensions could be whitelisted

    for my $entry( @{ $self->whitelist || [] } ) {
        next unless $entry =~ /^\d+x\d+x\d+$/i; # ignore anthing but dimensions

        $entry = lc($entry);

        return 1 if $dim eq $entry;
    }

    return 0; # Dimension is not in whitelist
}

sub blacklist { shift->{'blacklist'} }

sub has_blacklist_with_colors {
    my $self = shift;

    return scalar( grep { /^[a-z]/i } @{ $self->blacklist || [] } );
}

sub has_blacklist_with_dimensions {
    my $self = shift;

    return scalar( grep { /^\d+x\d+x\d+$/i } @{ $self->blacklist || [] } );
}

sub color_is_blacklisted {
    my $self = shift;
    my $cid  = shift;

    return 0 if ! $self->has_blacklist_with_colors; # return false if there is no blacklist, meaning no color is blacklisted

    for my $entry( @{ $self->blacklist || [] } ) {
        next unless $entry =~ /^[a-z]/i; # If there is at least a letter at the beginning then this entry has a color we can check

        my ($color) = split('_', $entry); # Entries can be either a color, a block identifier or just block dimensions so just get the color
        $color = uc($color);

        return 1 if $cid eq $color;
    }

    return 0; # Color is not in blacklist
}

sub dimension_is_blacklisted {
    my $self = shift;
    my $dim  = lc(shift);

    return 0 if ! $self->has_blacklist_with_dimensions; # return true if there is no blacklist, meaning all dimensions could be blacklisted

    for my $entry( @{ $self->blacklist || [] } ) {
        next unless $entry =~ /^\d+x\d+x\d+$/i; # ignore anthing but dimensions

        $entry = lc($entry);

        return 1 if $dim eq $entry;
    }

    return 0; # Dimension is not in blacklist
}



=pod

=head1 NAME

Lego::From::PNG - Convert PNGs into plans to build a two dimensional lego replica.

=head1 SYNOPSIS

  use Lego::From::PNG;

  my $object = Lego::From::PNG;

  $object->brick_tally();

=head1 DESCRIPTION

Convert a PNG into a block list and plans to build a two dimensional replica of the PNG.

=head1 USAGE

=head2 new

 Usage     : ->new()
 Purpose   : Returns Lego::From::PNG object

 Returns   : Lego::From::PNG object
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 lego_colors

 Usage     : ->lego_colors()
 Purpose   : Returns lego color constants consolidated as a hash.

 Returns   : Hash ref with color constants keyed by the official color name in key form.
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 lego_bricks

 Usage     : ->lego_bricks()
 Purpose   : Returns a list of all possible lego bricks

 Returns   : Hash ref with L<Lego::From::PNG::Brick> objects keyed by their identifier
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
 Argument  : filename  => the PNG to load and part
             unit_size => the pixel width and height of one unit, blocks are generally identified as Nx1 blocks where N is the number of units of the same color
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

=head2 process

 Usage     : ->process()
 Purpose   : Convert a provided PNG into a list of lego blocks that will allow building of a two dimensional lego replica.

 Returns   : Hashref containing information about particular lego bricks found to be needed based on the provided PNG.
             Also included is the build order for those bricks.
 Argument  : view => 'a view' - optionally format the return data. options include: JSON and HTML
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

=head2 _generate_brick_list

 Usage     : ->_approximate_lego_colors()
 Purpose   : Generate a list of lego colors based on a list of blocks ( array of hashes containing rgb values )

 Returns   : A list of lego color common name keys that can then reference lego color information using L<Lego::From::PNG::lego_colors>
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 whitelist

 Usage     : ->whitelist()
 Purpose   : return any whitelist settings stored in this object

 Returns   : an arrayref of whitelisted colors and/or blocks, or undef
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 has_whitelist_with_colors

 Usage     : ->has_whitelist_with_colors()
 Purpose   : return a true value if there is a whitelist with at least one color in it, otherwise a false value is returned

 Returns   : 1 or 0
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 has_whitelist_with_dimensions

 Usage     : ->has_whitelist_with_dimensions()
 Purpose   : return a true value if there is a whitelist with at least one dimension measurement in it, otherwise a false value is returned

 Returns   : 1 or 0
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 color_is_whitelisted

 Usage     : ->color_is_whitelisted($color_id)
 Purpose   : return a true value if the color is whitelisted, otherwise a false value is returned

 Returns   : 1 or 0
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 dimension_is_whitelisted

 Usage     : ->dimension_is_whitelisted($dimension)
 Purpose   : return a true value if the dimension is whitelisted, otherwise a false value is returned

 Returns   : 1 or 0
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 blacklist

 Usage     : ->blacklist
 Purpose   : return any blacklist settings stored in this object

 Returns   : an arrayref of blacklisted colors and/or blocks, or undef
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 has_blacklist_with_colors

 Usage     : ->has_blacklist_with_colors()
 Purpose   : return a true value if there is a blacklist, otherwise a false value is returned

 Returns   : 1 or 0
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 has_blacklist_with_dimensions

 Usage     : ->has_blacklist_with_dimensions()
 Purpose   : return a true value if there is a blacklist with at least one dimension measurement in it, otherwise a false value is returned

 Returns   : 1 or 0
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 color_is_blacklisted

 Usage     : ->color_is_blacklisted($color_id)
 Purpose   : return a true value if the color is blacklisted, otherwise a false value is returned

 Returns   : 1 or 0
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 dimension_is_blacklisted

 Usage     : ->dimension_is_blacklisted($dimension)
 Purpose   : return a true value if the dimension is blacklisted, otherwise a false value is returned

 Returns   : 1 or 0
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

