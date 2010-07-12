package Acme::Minify;

use base Exporter;

use warnings;
use strict;

=head1 NAME

Acme::Minify - Minify that long Perl code

=head1 VERSION

Version 0.01

=cut

our $VERSION   = '0.01';

our @EXPORT_OK = qw(minify);

=head1 SYNOPSIS

Acme::Minify minifies Perl code.

    use Acme::Minify;

    my $short_code = minify( $long_code );

=head1 DESCRIPTION

This packages removes most of the unnecessary characters from Perl code.
It clean-ups most of the whitespaces, the comments, newlines and converts
every tab in whitespace.

=head1 EXPORT

The module export the subroutine 'minify' on request.

=head1 SUBROUTINES

=head2 minify( $long_code )

Minify the code passed

=cut

sub minify {
	my $data = shift;
	my ($out, %flags);

	# set flags to 0
	$flags{'string'}  	= 0;
	$flags{'comment'} 	= 0;
	$flags{'regex'}		= 0;

	# remove POD with regex
	$data =~ s/=head1(\n|.)*?=cut//g;
	my @array = split(//, $data);

	for (my $i = 0; $i < scalar @array; $i++) {
		my $curr = $array[$i];
		my $next = $array[$i+1] ? $array[$i+1] : " ";
		my $prev = $array[$i-1];

		$flags{'skip'} = 0;

		# keep quoted characters
		if ($curr eq "\\") {
			if ($flags{'string'}) {
				$out .= "$curr$next";
			}

			$i++;
			next;
		}

		# keep strings
		if (($curr eq "\"") or ($curr eq "'")) {
			if (!$flags{'string'}) {
				$flags{'string'} = $curr;
			} elsif ($flags{'string'} eq $curr) {
				$flags{'string'} = 0;
			}
		}

		# keep regexes
		if ($curr eq "/") {
			
			if (!$flags{'regex'} and !$flags{'string'}) {

				if ($prev eq 's') {
					$flags{'regex'} = 3;
				} else {
					$flags{'regex'} = 2;
				}
			}

			$flags{'regex'}-- if !$flags{'string'};
		}

		# remove comments
		if ($curr eq '#') {
			$flags{'comment'} = 1 if $prev ne "\$" and
						 !$flags{'string'} and
						 !$flags{'regex'};
		}

		# replace tabs with spaces
		if ($curr eq "\t") {
			$curr = ' ' if !$flags{'string'} and !$flags{'regex'};
		}

		# replace newlines with spaces
		if ($curr eq "\n") {
			$flags{'comment'} = 0 if $flags{'comment'};
			$curr = ' ' if !$flags{'string'} and !$flags{'regex'};
		}

		# remove spaces only when it is safe 
		if ($curr eq ' ') {
			my @chars = ("+", "-", "=", "!", ",", ";", ">",
				     "<", "(", ")", "[", "]", "{", "}",
				     "\$", "@", "%", "'", "\"", "\n",
				     "\t", " ", "~");
			
			if (!$flags{'string'} and !$flags{'regex'}) {
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
