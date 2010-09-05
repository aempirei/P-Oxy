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
# convert a text grammar rule to a type prefix which is just a prefix sequence of type strings
#

sub rule_to_prefix {

	my $rule = shift;
	my $prefix = [];
	my $left = $rule;

	while($left =~ /\A(<[^>]+>|[+*])\s*/) {

		# there are exactly 3 kinds of prefix nodes:
		# a normal type string and a 0 or more star and a 1 or more star

		push @$prefix, $1;
		$left = $';
	}

	die 'unparsable grammar rule: '.$left if($left ne '');

	return $prefix;
}

#
# one grammar rule per line (but some grammar rules are combined via '|' (logical OR)
#

sub get_grammar {

	my $data = shift;

	my $rules = {};

	my $prefixes = [];

	foreach my $line (split(/\n/, $data)) {

    	last if($line =~ /^==EOF==$/);
		
		if($line =~ /^(\s*)--/) {

			# skip comments

	    } elsif($line =~ /(\S+)\s*:=\s*(.*?)\s*$/) {

	        my $key = $1;
	        my $tail = $2;

			my @rules_list = split(/\s+\|\s+/, $tail);
			#
			# parse out each subrule via '|' and then assign an array of each potential rule
			# this grammar tree starts from the smaller rules as keys to the larger rules as values
			#

			foreach my $rule (@rules_list) {

				my $prefix = rule_to_prefix($rule);

				my $normal_rule = join(' ', @$prefix);

				#
				# make sure the key doesnt exist but if it does just add the extra rules to the entry
				#

				$rules->{$normal_rule} = {} unless(defined $rules->{$normal_rule});

				$rules->{$normal_rule}->{$key} = rule_to_prefix($key);

				#
				# convert the rule into the actual type prefix
				#

				push @$prefixes, $prefix;
			}
	    }
	}

	return [ $rules, $prefixes ];
}

END { }

1;
