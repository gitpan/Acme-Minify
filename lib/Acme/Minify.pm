package Acme::Minify;
BEGIN {
  $Acme::Minify::VERSION = '0.07';
}

use Pod::Strip;
use base Exporter;

use warnings;
use strict;

our @EXPORT_OK = qw(minify);

=head1 NAME

Acme::Minify - Minify that long Perl code

=head1 VERSION

version 0.07

=head1 SYNOPSIS

Acme::Minify minifies Perl code.

    use Acme::Minify qw(minify);

    my $short_code = minify( $long_code );

=head1 DESCRIPTION

This packages removes most of the unnecessary characters from Perl code.

=over 4

=item * Comments are removed

=item * POD is removed

=item * Quoted strings (" ' `) and regexes are preserved

=item * \t and \n are converted in whitespaces

=item * __DATA__ and __END__ are preserved

=item * Spaces are removed if it doesn't affect syntax correcteness

=back

=head1 EXPORT

The module exports the subroutine 'minify' on request.

=head1 SUBROUTINES

=head2 minify( $long_code )

Minify the given source code

=cut

sub minify {
	my $code = shift;
	my ($out, %flags);

	# set flags to 0
	$flags{'string'}  = 0;
	$flags{'comment'} = 0;
	$flags{'regex'} = 0;

	# remove POD
	my $tmp;
	my $p = Pod::Strip -> new;
	$p -> output_string(\$tmp);
	$p -> parse_string_document($code);
	$code = $tmp;

	my ($end, $data);
	# preserve __END__
	if ($code =~ s/\n__END__\n((\n|.)*?)$//)  { $end = $1; }

	# preserve __DATA__
	if ($code =~ s/\n__DATA__\n((\n|.)*?)$//) { $data = $1; }

	my @array = split(//, $code);
	for (my $i = 0; $i < scalar @array; $i++) {
		my $curr = $array[$i];
		my $next = $array[$i+1] ? $array[$i+1] : " ";
		my $prev = $array[$i-1];

		# keep quoted characters
		if (($curr eq "\\") and !$flags{'comment'}) {
			$out .= "$curr$next";

			$i++;
			next;
		}

		# keep regexes
		if (($curr eq "/") and !$flags{'comment'}) {
			if (!$flags{'regex'} and !$flags{'string'}) {
				if ($prev eq 's') {
					$flags{'regex'} = 3;
				} else {
					$flags{'regex'} = 2;
				}
			}
			$flags{'regex'}-- if !$flags{'string'};
		}

		# keep strings
		if ((($curr eq "\"") or ($curr eq "'")
				     or ($curr eq "`"))
				     and !$flags{'comment'}) {
			if (!$flags{'string'}) {
				$flags{'string'} = $curr;
			} elsif ($flags{'string'} eq $curr) {
				$flags{'string'} = 0;
			}
		}

		if ((!$flags{'string'}) and (!$flags{'regex'})) {

			# remove comments
			$flags{'comment'} = 1 if ($prev ne "\$") and ($curr eq '#');

			# replace tabs with spaces
			$curr = ' ' if ($curr eq "\t");

			# replace newlines with spaces
			if ($curr eq "\n") {
				$flags{'comment'} = 0 if $flags{'comment'};
				$curr = ' ';
			}

			# remove spaces only when it is safe
			if ($curr eq ' ') {
				# safe whitespace removal
				my @chars = ("+", "-", "=", "!", ",",
					     ";", ">", "<", "(", ")",
					     "[", "]", "{", "}", "\$",
					     "@", "%", "'", "\"", "\n",
					     "\t", " ", "~", ".");

				foreach (@chars) {
					if (($_ eq $prev) or ($_ eq $next)) {
						$curr = "";
					}
				}
			}
		}

		next if $flags{'comment'};
		$out .= $curr;
	}

	$out .= "\n__END__\n$end"   if $end;
	$out .= "\n__DATA__\n$data" if $data;

	return $out;
}

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 ACKNOWLEDGEMENTS

This module is highly unstable and his behaviour could be unpredictable
in some cases as it has not been tested very deeply. Just to make things
obvious, it is not intended for production code.

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Acme::Minify