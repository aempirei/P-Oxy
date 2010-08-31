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

	# until primary sequence is <document>

		# while no substitution occurs
			# consume tokens until complete prefix match is found
			# if no prefix match is found then output node to queue and step forward in primary
			# otherwise unget substitution to primary and break

		# if queue and primary are same then error
	
		# swap queue for primary sequence and rewind
}
