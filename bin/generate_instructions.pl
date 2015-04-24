#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Lego::From::PNG;

use Data::Debug;

my $file = shift @ARGV;

my $png = Lego::From::PNG->new({ filename => $file });

my $result = $png->process;

#debug $result;

#debug $png->lego_colors;

my @list = sort map {
 $png->lego_colors->{ $_->{'color'} }{'common_name'} . ' ' . $_->{'width'} . ' x ' . $_->{'height'} . ' - ' . $_->{'quantity'} . ' bricks'
} values %{ $result->{'bricks'} };

my $row = 0;
my @plan = map {
 my $txt = '';
 $txt = "\n\n".$_->{'y'}.': ' and $row = $_->{'y'} if $row != $_->{'y'};
 $txt .= $png->lego_colors->{ $_->{'color'} }{'common_name'} . '(' . $_->{'width'} . ' x ' . $_->{'height'} . ')  ';
 $txt;
} @{ $result->{'plan'} };


my $total = 0;
for my $brick(values %{ $result->{'bricks'} }) {
    $total += $brick->{'quantity'};
}

print $total . " Total Bricks\n\n";
print "Shopping List\n-------------------------------------------------------------------------\n";
print $_,"\n" for @list;
print "\nPlan\n-------------------------------------------------------------------------\n";
print '0: ';
print $_ for @plan;
