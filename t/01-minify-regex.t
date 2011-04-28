#!perl -T

use Acme::Minify qw(minify);

use Test::More tests => 1;


my $code = 'm/simple regex   with random     spaces/;
m/?(\d[\d.-]+)\.(?:tar(?:\.gz|\.bz2)?|tgz|zip)$/;
s/something/some	thing/;';
my $minify = 'm/simple regex   with random     spaces/;m/?(\d[\d.-]+)\.(?:tar(?:\.gz|\.bz2)?|tgz|zip)$/;s/something/some	thing/;';

is(minify($code), $minify, "Test minified regex");
