#!/usr/bin/perl

# 2020 Earl Schellhous
# written to copy files from my Android phone to my Macintosh iMac external hard drive
# checks if file on phone exists on external hard drive
# Android volumes are mounted using SyncMate https://www.sync-mac.com/ 

=head1 name

CopyPix

=head1 DESCRIPTION

A simple script to copy files from a phone to a hard drive for backup.
Checks if file exists on hard drive before copying.

=head1 AUTHOR

Earl Schellhous 2020

=head1 LICENSE

GNU General Public License v3.0

=head1 INSTALLATION

Perl 5.18.4 was used to develop this
  
Change constants DIR_1, DIR_2 and DIR_3 to your directories and run the script.
Remove code for DIR_2 if not using SD card for photo storage

=cut

use strict;
use warnings;
use File::Find;
use File::Basename;
use File::Copy;
use feature qw(say);

use constant {
  # CHANGE THESE PATHS TO YOUR PATHS
  # stuff that is saved to the "normal" directory
  DIR_1 => '/Users/earl/.SMVolumes/SM-G955U 3369-CE5F/DCIM/',
  # stuff that is saved to the SD card - remove if you don't use SD card
  # btw this sometimes works on my Samsung and sometimes not even when camera preferences are set for SD card 
  # - hence the need to still scan the "normal directory"
  DIR_2 => '/Users/earl/.SMVolumes/SM-G955U sdcard/DCIM/',
  # the master directory where I have been storing photos from my phone
  DIR_3 => '/Volumes/LACIE SHARE/Samsung S8 pics/',
};

# where to store the find results
my %dir_1;
my %dir_2;
my %dir_3;

# used by File::Basename::fileparse
# seems to me @suffixlist acts like a filter so I'll use it that way
my @suffixlist = ('.jpg','.jpeg','.mp4');
# used to display the results of compare_hashes()
my @report;

say "vars initialized";

# find files in the first directory and below
find ( sub {
        if ( -f $File::Find::name ) {
          my ($filename, $dir, $suffix) = fileparse($File::Find::name,@suffixlist);
            # exclude thumbnails and screenshots
            if($suffix and not $File::Find::name =~ qr/thumb/i and not $File::Find::name =~ qr/screenshot/i){
              $dir_1{$filename . $suffix} = $File::Find::name;
              # say "$File::Find::name";
            }
        } else {
            $dir_1{$File::Find::name} = "DIRECTORY!";
        }
}, DIR_1);

print "End of collecting'%dir_1'\n\n";

# find files in the second directory and below
#remove if you don't use SD card
find ( sub {
        if ( -f $File::Find::name ) {
          my ($filename, $dir, $suffix) = fileparse($File::Find::name,@suffixlist);
            # exclude thumbnails and screenshots
            if($suffix and not $File::Find::name =~ qr/thumb/i and not $File::Find::name =~ qr/screenshot/i){
              $dir_2{$filename . $suffix} = $File::Find::name;
              # say "$File::Find::name";
            }
        } else {
            $dir_2{$File::Find::name} = "DIRECTORY!";
        }
}, DIR_2);

print "End of collecting'%dir_2'\n\n";

# find files in the third directory and below
find ( sub {
        if ( -f $File::Find::name ) {
          my ($filename, $dir, $suffix) = fileparse($File::Find::name,@suffixlist);
          if($suffix){
            $dir_3{$filename . $suffix} = $File::Find::name;
            # say "$File::Find::name";
          }
        } else {
            $dir_3{$File::Find::name} = "DIRECTORY!";
        }
}, DIR_3);

print "End of collecting'%dir_3'\n\n";

say "Comparing first and third directories";

copy_pics(\%dir_1, \%dir_3);

say "Done with " . DIR_1;
print "\n";

copy_pics(\%dir_2, \%dir_3);

say "Done with " . DIR_2;
print "\n";

die "All Done!";

# compare external hard drive files with files on phone and copy those that don't exist on the hard drive to the hard drive
# not sure where I downloaded the original script for this sub but this has been modified quite a bit
sub copy_pics {
    my ($first, $second) = @_;
    my @report;
    foreach my $k (keys %{ $first }) {
      # say "Looking at " . '$first->{$k}';
      # say '$first->{$k} = ' . $first->{$k};
      # say '$k = ' . $k;
      # if the file is a file and doesn't exist on the hard drive, copy one to it
      if(not exists $second->{$k}){
        if($first->{$k} ne "DIRECTORY!"){
          say $k . " does not exist in " . DIR_3;
          say "Copying $k to " . DIR_3;
          copy($first->{$k}, DIR_3) or die "Copying $first->{$k} to " . DIR_2 . "\n" . "Copy failed: " . $!;
        }else{
          say "Skipping directory at " . $k;
        }
      }
    }
    return @report;
}
