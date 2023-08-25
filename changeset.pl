#!/usr/bin/perl

# Adapter script for Changeset.pm module
# exports Changeset.pm functionality for command line use.

use strict;
use FindBin;
use lib $FindBin::Bin;
use Changeset;

if ($ARGV[0] eq "create")
{
    my $cs = Changeset::create($ARGV[1]);
    print "changeset created: $cs\n" if defined($cs);
}
elsif ($ARGV[0] eq "close")
{
    if (!defined($ARGV[2]) || Changeset::update($ARGV[1], $ARGV[2]))
    {
        if (Changeset::close($ARGV[1]))
        {
            print "changeset closed.\n";
        }
    }
}
elsif (($ARGV[0] eq "upload") && (scalar(@ARGV)==2))
{
    my $body = "";
    while(<STDIN>) { $body .= $_; }
    if (length($body) == 0)
    {
    	print "usage: $0 upload <id> < content-to-upload\n";
	exit;
    }
    if (Changeset::upload($ARGV[1], $body))
    {
        print "changeset uploaded.\n";
    }
}
elsif (($ARGV[0] eq "comment") && (scalar(@ARGV)==3))
{
    if (Changeset::comment($ARGV[1], $ARGV[2]))
    {
        print "comment added.\n";
    }
}
elsif (($ARGV[0] eq "download") && (scalar(@ARGV)==2))
{
    print Changeset::download($ARGV[1]);
    print "\n";
}
elsif (($ARGV[0] eq "download-versions") && (scalar(@ARGV)==2))
{
    my $content = Changeset::download($ARGV[1]);
    print "$_\n" for Changeset::get_element_versions($content);
}
else
{
    print <<EOF;
Usage: 
  $0 create [<comment>]      to create a changeset; returns ID created
  $0 close <id> [<comment>]  to close a changeset and optionally set comment
  $0 upload <id> <content>   to upload changes to an open changeset
  $0 comment <id> <comment>  to comment on an existing changeset
  $0 download <id>           to download and display an existing changeset
  $0 download-versions <id>  to download and display element versions of a changeset
EOF
    exit;
}
