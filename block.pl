#!/usr/bin/perl

# Adapter script for Block.pm module
# exports Block.pm functionality for command line use.

use strict;
use FindBin;
use lib $FindBin::Bin;
use Block;

if ((($ARGV[0] eq "create") || ($ARGV[0] eq "create-on-uid")) && (scalar(@ARGV) == 4))
{
    my $desc = "";
    while(<STDIN>) { $desc .= $_; }
    if (length($desc) == 0)
    {
    	print "usage: $0 create <user> <duration> <needs_view> < file-with-description\n";
        exit;
    }

    my $blk;
    if ($ARGV[0] eq "create-on-uid")
    {
        $blk = Block::create_on_id($ARGV[1], $desc, $ARGV[2], $ARGV[3]);
    }
    else
    {
        $blk = Block::create($ARGV[1], $desc, $ARGV[2], $ARGV[3]);
    }
    print "block created: $blk\n" if defined($blk);
}
else
{
    print <<EOF;
Usage: 
  $0 create <user> <duration> <needs_view>        create block; description on stdin; returns id
  $0 create-on-uid <uid> <duration> <needs_view>  same but for user with given id if the api supports it
EOF
    exit;
}
