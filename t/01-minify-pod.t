#!perl -T

use Acme::Minify qw(minify);

use Test::More tests => 1;

my $code = <<EOS;
package Test::Minify::Pod;

use warnings;
use strict;

=head1 NAME

Test::Minify::Pod - Test minifying of POD

=head1 SYNOPSIS

Just for test

=cut

sub some_sub {
	return 0;
}
EOS

my $minify = 'package Test::Minify::Pod;use warnings;use strict;sub some_sub{return0;}';

is(minify($code), $minify, "Test minified pod");
