#!perl -T

use Acme::Minify qw(minify);

use Test::More tests => 1;

my $code = '
use Some::Module;

sub something {
	return 0;
}


__DATA__
Some data here
that
must be preserved';


my $minified_code = 'use Some::Module;sub something{return0;}
__DATA__
Some data here
that
must be preserved';

is(minify($code), $minified_code, "Test minified __DATA__");
