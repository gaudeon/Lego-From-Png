package Lego::From::PNG::View;

use strict;
use warnings;

use Data::Debug;

sub new {
    my $class = shift;
    my $hash = {};

    my $self = bless ($hash, ref ($class) || $class);

    return $self;
}

sub print {
    my $self = shift;

    return @_; # Don't do anything, just return what they send us
}

=pod

=head1 NAME

Lego::From::PNG::View - Format data returned from Lego::From::PNG

=head1 SYNOPSIS

  use Lego::From::PNG;

  my $object = Lego::From::PNG->new({ filename => 'my_png.png' });

  $object->process(view => 'JSON'); # Data is returned as JSON

=head1 DESCRIPTION

Base class for formatting data returned from processing a PNG

=head1 USAGE

=head2 new

 Usage     : ->new()
 Purpose   : Returns Lego::From::PNG::View object

 Returns   : Lego::From::PNG::View object
 Argument  :
 Throws    :

 Comment   : This is just a base class so this shouldn't be directly used to format data
 See Also  :

=head2 print

 Usage     : ->print()
 Purpose   : Returns formated input data

 Returns   : In the case of the base class the args passed are just returned back
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

