package Acme::Minify;

use base Exporter;

use warnings;
use strict;

=head1 NAME

Acme::Minify - Minify that long Perl code

=head1 VERSION

Version 0.05

=cut

our $VERSION   = '0.05';

our @EXPORT_OK = qw(minify);

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

	# remove POD
	$code =~ s/\n=head1(\n|.)*?\n=cut//g;

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

		if (!$flags{'string'}) {

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

Alessandro Ghedini, C<< <alexbio at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-acme-minify at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Acme-Minify>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Acme::Minify

You can also look for information at:

=over 4

=item * GitHub

L<http://github.com/AlexBio/Acme-Minify>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Acme-Minify>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Acme-Minify>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Acme-Minify>

=item * Search CPAN

L<http://search.cpan.org/dist/Acme-Minify/>

=back

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
