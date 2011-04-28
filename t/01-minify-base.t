#!perl -T

use Acme::Minify qw(minify);

use Test::More tests => 1;

my $code = '
use Some::Module;

sub something {
	return 0;
}

do_something_here(  )  ;

my    $var   =  some_function();
';

my $minified_code = 'use Some::Module;sub something{return0;}do_something_here();my$var=some_function();';

is(minify($code), $minified_code, "Test minified code");
