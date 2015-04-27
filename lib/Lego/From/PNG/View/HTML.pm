package Lego::From::PNG::View::HTML;

use strict;
use warnings;

use parent qw(Lego::From::PNG::View);

use Data::Debug;

sub print {
    my $self = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    my @styles;
    my @brick_list;

    push @styles, '.lego_instructions td { height: 1em; }';

    for my $color (sort { $a->{'color'}.$a->{'length'} cmp $b->{'color'}.$b->{'length'} } values %{$args{'bricks'}}) {
        my $cid = $color->{'color'};
        my $lego_color = $self->png->lego_colors->{$cid};

        push @styles, '.'.lc($cid).' { background: #'.$lego_color->{'hex_color'}.'; }';
        push @brick_list, '<tr><td>'.$lego_color->{'official_name'}.' '.join('x',@{$color}{qw(depth length height)}).'</td><td>'.$color->{'quantity'}.'</td></tr>';
    }

    my $html;

    # Styles
    $html .= qq{<style>\n};
    $html .= $_."\n" for @styles;
    $html .= qq{</style>\n\n};

    # Heading
    $html .= qq{<h1>Brick List and Instructions</h1>\n\n};

    # Brick List
    $html .= qq{<h2>Brick List</h2>\n};
    $html .= qq{<table class="lego_list"><thead><tr><th>Brick</th><th>Quantity</th></thead><tbody>\n};
    $html .= $_."\n" for @brick_list;
    $html .= qq{</tbody></table>\n\n};

    # Instructions
    $html .= qq{<h2>Instructions</h2>\n};
    $html .= qq{<table class="lego_instructions" border="1"><tbody>\n};
    $html .= qq{<tr>}; # first <tr>
    my $y = 0;
    for my $color (@{$args{'plan'}}) {
        my ($class, $colspan) = (lc($color->{'color'}),$color->{'length'});
        if($y != $color->{'meta'}{'y'}) {
            $html .= qq{</tr>\n};
            $y = $color->{'meta'}{'y'};
        }
        $html .= qq[<td colspan="$colspan" class="$class" style="width: ${colspan}em;"></td>];
    }
    $html .= qq{</tr>\n}; # last </tr>
    $html .= qq{</tbody></table>\n};

    return $html;
}

=pod

=head1 NAME

Lego::From::PNG::View::HTML - Format data returned from Lego::From::PNG

=head1 SYNOPSIS

  use Lego::From::PNG;

  my $object = Lego::From::PNG->new({ filename => 'my_png.png' });

  $object->process(view => 'HTML'); # Data is returned as HTML

=head1 DESCRIPTION

Class to returned processed data in HTML format

=head1 USAGE

=head2 new

 Usage     : ->new()
 Purpose   : Returns Lego::From::PNG::View::HTML object

 Returns   : Lego::From::PNG::View::HTML object
 Argument  :
 Throws    :

 Comment   :
 See Also  :

=head2 print

 Usage     : ->print({}) or ->print(key1 => val1, key2 => val2)
 Purpose   : Returns HTML formated data (in utf8 and pretty format)

 Returns   : Returns HTML formated data (in utf8 and pretty format)
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

