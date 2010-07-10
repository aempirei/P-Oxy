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
# just dump out the intermediate data
#

foreach my $rule (keys(%grammar)) {
	printf("%s := %s\n", $rule, join(' | ', keys(%{$grammar{$rule}})));
}

foreach my $tt (@tokens) {
	my ($type, $token) = @$tt;
	printf("%15s %-15s %s\n", $type, $token, 0);
}
