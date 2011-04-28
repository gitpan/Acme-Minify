#!perl -T

use Acme::Minify qw(minify);

use Test::More tests => 1;

my $code = '
my $string = <<EOS;
some
multiline
string

asdhkfbkadfjgs

afdg sfdg sfdg
EOS
';

my $minify = 'my$string=<<EOS;
some
multiline
string

asdhkfbkadfjgs

afdg sfdg sfdg
EOS';

TODO: {
	local $TODO = 'fix here-doc minification';

	is(minify($code), $minify, "Test minified here-doc");
}
