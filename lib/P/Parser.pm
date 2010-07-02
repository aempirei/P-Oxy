#
# Grammar Parser for The P Programming Language
#
# Copyright(c) 2010 by Christopher Abad
# aempirei@gmail.com
#

package P::Parser;

use strict;
use warnings;


BEGIN {
	use Exporter ();
	our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

	$VERSION = 1.00;

	@ISA = qw(Exporter);
	@EXPORT = qw();
	%EXPORT_TAGS = ( );

	@EXPORT_OK = qw();
}

our @EXPORT_OK;

#
# one grammar rule per line (but some grammar rules are combined via '|' (logical OR)
#

sub get_grammar {

	my $data = shift;

	my %grammar;

	foreach my $line (split(/\n/, $data)) {

    	last if($line =~ /^==EOF==$/);

	    if($line =~ /(\S+)\s*:=\s*(.*?)\s*$/) {

	        my $key = $1;
	        my $tail = $2;

			#
			# parse out each subrule via '|' and then assign an array of each potential rule
			#

			my @rules = split(/\s*\|\s*/, $tail);

			#
			# make sure the key doesnt exist but if it does just add the extra rules to the entry
			#

			$grammar{$key} = [ @rules ];
	    }
	}

	return %grammar;
}

END { }

1;
