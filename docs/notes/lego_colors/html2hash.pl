#!/usr/bin/env perl

=head1 html2hash.pl

A quick and dirty parser to rip out lego colors and export as a PERL hash for later use

=cut

use strict;
use warnings;

use Data::Dumper qw(Dumper);

my %colors;
my $state = 'find_color';
my $current = '';

while(<>) {
    chomp;
    SWITCH: {
        $state =~ /^find_color$/ && do {
            next unless m|a href="/wiki/([^"]+)"|;
            $current = $1;
            my $split = join(' ',split(/_/, $current));
            $current = uc($current);
            $current =~ s/-/_/g;
            $colors{$current} = {
                official_name => $split,
                common_name   => '',
                hex_color     => '',
                rgb_color     => [],
            };
            $state = 'color_data';
            last SWITCH;
        };
        $state =~ /^color_data$/ && do {
            if(m|background:#([a-f A-F 0-9]{3,6})|) {
                my $color = uc($1);
                $color = join('', map { $_ . $_ } split('', $color)) if length($color) == 3;
                $colors{$current}{'hex_color'} = $color;
                my @rgb = unpack 'C*', pack 'H*', $color;
                $colors{$current}{'rgb_color'} = \@rgb;
                $state = 'find_color';
                last SWITCH;
            }
            elsif(m|</td><td>\s*(.+)|) {
                $colors{$current}{'common_name'} = $1;
                last SWITCH;
            }
        };
    }
}

print "HASH\n";
print Dumper(\%colors);

print "\n\nCOLOR CONST LIST\n";
print "    LEGO_COLORS\n";
print "    " . $_ . "_OFFICIAL_NAME\n" .
      "    " . $_ . "_COMMON_NAME\n" .
      "    " . $_ . "_HEX_COLOR\n" .
      "    " . $_ . "_RGB_COLOR_RED\n" .
      "    " . $_ . "_RGB_COLOR_GREEN\n" .
      "    " . $_ . "_RGB_COLOR_BLUE\n" for sort keys %colors;

print "\n\nCOLOR LIST CONSTANT\n";
print "LEGO_COLORS => qw(\n";
print "    " . $_ . "\n" for sort keys %colors;
print ");";

print "\n\nCOMMON NAME CONSTANTS\n";
print "    " . $_ . "_OFFICIAL_NAME => " . "'" . $colors{$_}{'official_name'} . "',\n" .
      "    " . $_ . "_COMMON_NAME => " . "'" . $colors{$_}{'common_name'} . "',\n" .
      "    " . $_ . "_HEX_COLOR => " . "'" . $colors{$_}{'hex_color'} . "',\n" .
      "    " . $_ . "_RGB_COLOR_RED => " . $colors{$_}{'rgb_color'}[0] . ",\n" .
      "    " . $_ . "_RGB_COLOR_GREEN => " . $colors{$_}{'rgb_color'}[1] . ",\n" .
      "    " . $_ . "_RGB_COLOR_BLUE => " . $colors{$_}{'rgb_color'}[2] . ",\n\n" for sort keys %colors;
