#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Lego::From::PNG;

use Data::Debug;

my $file = shift @ARGV || die "PNG required";

my $png = Lego::From::PNG->new({ filename => $file, whitelist => [ whitelist() ], imperial => 1 });

# HTML
my $result = $png->process(view => HTML);
print $result;
exit;

# Text
my $result = $png->process;

my @list = sort map {
 $png->lego_colors->{ $_->{'color'} }{'official_name'} . ' ' . $_->{'depth'} . ' x ' . $_->{'length'} . ' x ' . $_->{'height'} . ' - ' . $_->{'quantity'} . ' ' . ($_->{'quantity'} > 1 ? 'bricks' : 'brick')
} values %{ $result->{'bricks'} };

my $row = 0;
my @plan = map {
 my $txt = '';
 $txt = "\n\n".$_->{'meta'}{'y'}.': ' and $row = $_->{'meta'}{'y'} if $row != $_->{'meta'}{'y'};
 $txt .= '[ ' . $png->lego_colors->{ $_->{'color'} }{'official_name'} . ' ' . $_->{'depth'} . ' x ' . $_->{'length'} . ' x ' . $_->{'height'} . ' ] ';
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

sub whitelist {
    return qw(
WHITE_1x1x1
WHITE_1x2x1
WHITE_1x3x1
WHITE_1x4x1
WHITE_1x6x1
WHITE_1x8x1
BRIGHT_RED_1x1x1
BRIGHT_RED_1x2x1
BRIGHT_RED_1x3x1
BRIGHT_RED_1x4x1
BRIGHT_RED_1x6x1
BRIGHT_BLUE_1x1x1
BRIGHT_BLUE_1x2x1
BRIGHT_BLUE_1x3x1
BRIGHT_BLUE_1x4x1
BRIGHT_BLUE_1x6x1
BRIGHT_BLUE_1x8x1
BRIGHT_YELLOW_1x1x1
BRIGHT_YELLOW_1x2x1
BRIGHT_YELLOW_1x3x1
BRIGHT_YELLOW_1x4x1
BRIGHT_YELLOW_1x6x1
BRIGHT_YELLOW_1x8x1
BLACK_1x1x1
BLACK_1x2x1
BLACK_1x3x1
BLACK_1x4x1
BLACK_1x6x1
BLACK_1x8x1
DARK_GREEN_1x1x1
DARK_GREEN_1x2x1
DARK_GREEN_1x4x1
DARK_GREEN_1x6x1
BRICK_YELLOW_1x1x1
BRICK_YELLOW_1x2x1
BRICK_YELLOW_1x3x1
BRICK_YELLOW_1x4x1
BRICK_YELLOW_1x6x1
BRICK_YELLOW_1x8x1
BRIGHT_ORANGE_1x1x1
BRIGHT_ORANGE_1x2x1
BRIGHT_ORANGE_1x3x1
BRIGHT_ORANGE_1x4x1
MEDIUM_BLUE_1x1x1
MEDIUM_BLUE_1x2x1
MEDIUM_BLUE_1x4x1
DARK_STONE_GREY_1x1x1
DARK_STONE_GREY_1x2x1
DARK_STONE_GREY_1x3x1
DARK_STONE_GREY_1x4x1
DARK_STONE_GREY_1x6x1
DARK_STONE_GREY_1x8x1
REDDISH_BROWN_1x1x1
REDDISH_BROWN_1x2x1
REDDISH_BROWN_1x3x1
REDDISH_BROWN_1x4x1
REDDISH_BROWN_1x6x1
REDDISH_BROWN_1x8x1
MEDIUM_STONE_GREY_1x1x1
MEDIUM_STONE_GREY_1x2x1
MEDIUM_STONE_GREY_1x3x1
MEDIUM_STONE_GREY_1x4x1
MEDIUM_STONE_GREY_1x6x1
MEDIUM_STONE_GREY_1x8x1
BRIGHT_YELLOWISH_GREEN_1x1x1
BRIGHT_YELLOWISH_GREEN_1x2x1
BRIGHT_YELLOWISH_GREEN_1x4x1
LIGHT_PURPLE_1x1x1
LIGHT_PURPLE_1x2x1
LIGHT_PURPLE_1x4x1
MEDIUM_AZUR_1x1x1
MEDIUM_AZUR_1x2x1
MEDIUM_AZUR_1x4x1
MEDIUM_AZUR_1x6x1
MEDIUM_LAVENDER_1x1x1
MEDIUM_LAVENDER_1x2x1
BRIGHT_REDDISH_VIOLET_1x1x1
BRIGHT_REDDISH_VIOLET_1x2x1
BRIGHT_REDDISH_VIOLET_1x4x1
BRIGHT_REDDISH_VIOLET_1x6x1
    );
}
