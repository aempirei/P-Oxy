#!/usr/bin/perl
#
# Grammar Tester for The P Programming Language
#
# Copyright(c) 2010 by Christopher Abad
# aempirei@gmail.com
#

use lib './lib';

use strict;
use warnings;
use P::Grammar;

#
# one grammar rule per line (but some grammar rules are combined via '|' (logical OR)
#

my $grammar_data = join('', <STDIN>);

#
# parse the grammar file
#

my $grammar = P::Grammar::get_grammar($grammar_data);

#
# dump out the parsed grammar spec.
#

sub print_grammar {

	my $grammar = shift;

	my ( $rules, $prefixes ) = @$grammar;

	foreach my $prefix (@$prefixes) {
		my $rule = P::Grammar::prefix_to_key($prefix);
		die "rule not found: $rule" unless(exists $rules->{$rule});
		printf("%s := %s\n", $rule, join(' | ', keys(%{$rules->{$rule}})));
	}
}

print_grammar($grammar);
