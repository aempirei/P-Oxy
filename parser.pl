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

my %grammar = P::Parser::get_grammar($grammar_data);
my @tokens = P::Lexer::get_tokens($program_data);

my %tree;

#
# dump out the parsed grammar spec.
#

foreach my $rule (keys(%grammar)) {
printf("%s := %s\n", $rule, join(' | ', keys(%{$grammar{$rule}})));
}

my @expr;

foreach my $tt (@tokens) {

	my ($type, $token) = @$tt;
	# printf("%15s %-15s %s\n", $type, $token, 0);

# for each token, look up all of the grammar matches based on the current sequence

	# for each token find each grammar match.
	# a grammar match rule is a regular expression of the sequence of tokens either of static or dynamic length but regular in form.
	# append each grammar match to that grammar sequence
	# if a gramar sequence is terminated in correct form, perform parent substitution and unshift the sub onto the head of tokens
	# if the document has ended then if we are at the root node, successful parse, otherwise parse failed
}
