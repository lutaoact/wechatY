use warnings;
use strict;

use JSON;
use Data::Dumper;

open my $fh, '<', 'lib/WordsForYang.txt' or die $!;
my $lines = [ map { chomp; $_ } <$fh> ];
print Dumper $lines;

my $outfile = 'lib/WordsForYang.json';
write_file($outfile, json_encode($lines));

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
