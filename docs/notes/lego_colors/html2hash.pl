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
            $colors{$current} = {
                official_name => $split,
                common_name   => '',
                hex_color     => '',
            };
            $state = 'color_data';
            last SWITCH;
        };
        $state =~ /^color_data$/ && do {
            if(m|background:#([a-f A-F 0-9]{6})|) {
                $colors{$current}{'hex_color'} = $1;
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

print Dumper(\%colors);
