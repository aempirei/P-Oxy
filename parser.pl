#!/usr/bin/perl
#
# Grammar Parser for The P Programming Language
#
# Copyright(c) 2010 by Christopher Abad
# aempirei@gmail.com
#

use lib './lib';

use strict;
use warnings;
use P::Lexer;
use P::Parser;

use IO::File;

my $grammar_file = 'poxy.grammar';

my $fh = IO::File::new;

$fh->open('<'.$grammar_file);

#
# one grammar rule per line (but some grammar rules are combined via '|' (logical OR)
#

my $program_data = join('', <STDIN>);
my $grammar_data = join('', <$fh>);

#
# parse the grammar file and tokenize the program data
#

my @grammar = P::Parser::get_grammar($grammar_data);
my @tokens = P::Lexer::get_tokens($program_data);

my %tree;

#
# dump out the parsed grammar spec.
#

my ( $rules, $prefixes ) = @grammar;

foreach my $prefix (@$prefixes) {
	my $rule = join(' ', @$prefix);
	die "rule not found: $rule" unless(exists $rules->{$rule});
	printf("%s := %s\n", $rule, join(' | ', keys(%{$rules->{$rule}})));
}

my $document = [@tokens];

foreach my $node (@$document) {
	my ( $type, $token ) = @$node;

	print "<$type:$token>\n";
}

	# then return

# for each possible substitution
	# attempt substitution
	# if recurse is 'document'
		# then return

# return error

