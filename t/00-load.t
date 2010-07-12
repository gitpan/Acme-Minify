#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Acme::Minify' ) || print "Bail out!
";
}

diag( "Testing Acme::Minify $Acme::Minify::VERSION, Perl $], $^X" );
