use warnings;
use strict;

use JSON;
use Data::Dumper;

open my $fh, '<', 'lib/keywords.txt' or die $!;
my $map = +{
  map {
    chomp;
    my ($key, $reply) = split /\s+/, $_;
    $key => $reply
  } <$fh>
};
print Dumper $map;

my $outfile = 'lib/keywords.json';
write_file($outfile, json_encode($map));

sub json_encode {
    my ($json_obj) = @_;
    my $JSON = JSON->new->allow_nonref;
    return $JSON->pretty->encode($json_obj);
}

sub write_file {
    my ($file, $text) = @_;
    open my $fh, '>', $file or die "$!";
    print $fh $text;
    close $fh;
}
