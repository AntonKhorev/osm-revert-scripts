#!/usr/bin/perl

use strict;
use FindBin;
use lib $FindBin::Bin;
use Getopt::Long;
use Node;
use Changeset;

my $latest_changeset = 0;
my $new_changeset = 0;
my $cid;
my $latest_version = 0;
my $reset = 0;
my ($version, $to_version);
my ($lat, $lon);
my $latlon;
my (@keys, @values, @tags, @tag_strings);
my (@delete_keys, @delete_values, @delete_tags, @delete_tag_strings);
my %tags;
my %delete_tags;
my $correct_options = GetOptions(
    "changeset|cid=i" => \$cid,
    "latest-changeset!" => \$latest_changeset,
    "new-changeset!" => \$new_changeset,
    "version=i" => \$version,
    "to-version=i" => \$to_version,
    "latest-version!" => \$latest_version,
    "reset!" => \$reset,
    "lat=f" => \$lat,
    "lon=f" => \$lon,
    "latlon|ll=s" => \$latlon,
    "key=s" => \@keys,
    "value=s" => \@values,
    "tag=s" => \@tags,
    "tags=s" => \@tag_strings,
    "delete-key=s" => \@delete_keys,
    "delete-values=s" => \@delete_values,
    "delete-tag=s" => \@delete_tags,
    "delete-tags=s" => \@delete_tag_strings,
);

if (($ARGV[0] eq "create") && (scalar(@ARGV) == 1) && $correct_options)
{
    process_arguments();
    require_latlon();
    my $id = Node::create($cid, \%tags, $lat, $lon);
    print "node created: $id\n" if defined($id);
    exit;
}

if (($ARGV[0] eq "delete") && (scalar(@ARGV) == 2) && $correct_options)
{
    my $id = $ARGV[1];
    process_arguments();
    require_version($id);
    my $new_version = Node::delete($cid, $id, $version);
    print "node deleted with version: $new_version\n" if defined($new_version);
    exit;
}

if (($ARGV[0] eq "modify") && (scalar(@ARGV) == 2) && $correct_options)
{
    my $id = $ARGV[1];
    process_arguments();
    require_version($id);
    die "can't have both --to-version and --reset" if defined($to_version) && $reset;
    require_latlon() if $reset;
    my $new_version = Node::modify($cid, $id, $version, $to_version, $reset, \%tags, \%delete_tags, $lat, $lon);
    print "node overwritten with version: $new_version\n" if defined($new_version);
    exit;
}

print <<EOF;
Usage: 
  $0 create <options>           create node
  $0 delete <id> <options>      delete node
  $0 modify <id> <options>      modify the existing node version

options:
  --changeset=<id>              \\
  --latest-changeset            - need one
  --new-changeset               /
  --version=<number>            \\
  --latest-version              - need one for updating
  --to-version=<number>
  --reset                       delete everything from node prior to modification
  --lat=<number>
  --lon=<number>
  --ll=<number,number>          shortcut for --lat=<number> --lon=<number>

options that can be passed repeatedly:
  --key=<string>
  --value=<string>
  --tag=<key>[=<value>]         shortcut for --key=<key> --value=<value>
  --tags=<key>=[<value>][,<key>=[<value>]...]
  --delete-key=<string>
  --delete-value=<string>
  --delete-tag=<key>[=<value>]  if value is specified, delete tag if both key and value match
  --delete-tags=<key>=[<value>][,<key>=[<value>]...]
EOF

sub process_arguments
{
    die "need exactly one of: (--latest-changeset, --new-changeset, --changeset=<id>)" unless $latest_changeset + $new_changeset + defined($cid) == 1;
    $cid = Node::get_latest_changeset() if $latest_changeset;
    $cid = Changeset::create() if $new_changeset;
    die unless defined($cid);

    if (defined($latlon))
    {
        die "can't have both --lat and --latlon" if defined($lat);
        die "can't have both --lon and --latlon" if defined($lat);
        ($lat, $lon) = split /,/, $latlon, 2;
    }

    %tags = process_tags("keys/values", \@keys, \@values, \@tags, \@tag_strings);
    %delete_tags = process_tags("delete-keys/values", \@delete_keys, \@delete_values, \@delete_tags, \@delete_tag_strings);
}

sub process_tags
{
    my ($name, $keys, $values, $tags, $tag_strings) = @_;
    die "different number of $name" unless @$keys == @$values;
    my %tags = map { split /=/, $_, 2 } (@$tags, map { split /,/ } @$tag_strings);
    @tags{@$keys} = @$values;
    return %tags;
}

sub require_latlon
{
    die "lat is missing" unless defined($lat);
    die "lon is missing" unless defined($lon);
}

sub require_version
{
    my ($id) = @_;
    die "need exactly one of: (--latest-version, --version=<n>)" unless $latest_version + defined($version) == 1;
    $version = Node::get_latest_version($id) if $latest_version;
    die unless defined($version);
}
