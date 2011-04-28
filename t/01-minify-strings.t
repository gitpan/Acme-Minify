#!perl -T

use Acme::Minify qw(minify);

use Test::More tests => 1;

my $code = '
my $var = "some double-quoted string";

$var = "some double-quoted string   with random      spaces";

$var = \'some single-quoted string\';

$var = \'some single-quoted string   with random      spaces\';
';

my $minify = 'my$var="some double-quoted string";$var="some double-quoted string   with random      spaces";$var=\'some single-quoted string\';$var=\'some single-quoted string   with random      spaces\';';

is(minify($code), $minify, "Test minified strings");
