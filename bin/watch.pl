#!/usr/bin/env perl

Script->new->run;
exit;

package Script;

use strict;
use warnings;

use FindBin qw($Bin);
use Filesys::Notify::Simple;
use Getopt::Long;
use TAP::Harness;
use Data::Debug;

use lib "$Bin/../lib";
use lib "$Bin/../t/lib";

use constant TESTDIR => "$Bin/../t";

sub new {
    my $class = shift;
    my $hash  = {};

    my ($verbose, $test);
    GetOptions(
        'verbose|v+' => \$verbose,
        'test|t=s'   => \$test,
    ) or die "Error in command line arguments\n";

    $hash->{'verbose'} = $verbose;

    $hash->{'test'} = $test;

    return bless $hash, $class;
}

sub run {
    my $self = shift;

    $self->test_all_the_things();

    my $watcher = Filesys::Notify::Simple->new([ "$Bin/../lib" ]);

    while(1) {
        $watcher->wait(sub {
            for my $event (@_) {
                next unless $event->{'path'} =~ /\.pm$/; # only test perl module changes

                $self->test_all_the_things();
            }
        });
    }
}

sub harness {
    my $self = shift;

    return $self->{'harness'} ||= do {
        my $h = TAP::Harness->new({
            verbosity => $self->{'verbose'} || 0,
            lib       => [ "$Bin/../lib", "$Bin/../t/lib" ],
        });

        $h;
    };
}

sub test_all_the_things {
    my $self = shift;

    my @test_files = @{ $self->test_files() };

    $self->clear();

    $self->harness->runtests( @test_files );
}

sub test_files {
    my $self = shift;

    return $self->{'test_files'} ||= do {
        my @test_files;

        my $test = $self->{'test'};

        opendir my $dh, TESTDIR or die "Could not open test directory $!";
        while(my $file = readdir($dh)) {
            next unless $file =~ /\.t$/;
            next unless ! $test || $file =~ m/$test/i;

            push @test_files, TESTDIR . "/$file";
        }
        closedir $dh;

        die "No tests found to run" unless scalar @test_files;

        \@test_files;
    };
}

sub clear {
    print "\033[2J";    #clear the screen
    print "\033[0;0H"; #jump to 0,0
}

1;
