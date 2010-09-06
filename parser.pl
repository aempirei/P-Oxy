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
use P::Grammar;
use P::Parser;
use IO::File;
use HTML::Entities;

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

my $grammar = P::Grammar::get_grammar($grammar_data);
my $tokens = P::Lexer::get_tokens($program_data);
my $tree = P::Parser::get_tree($tokens, $grammar);

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

sub print_document {
	my $document = shift;
	print '<?xml version="1.0"?><source>'.document_to_string($document)."</source>\n";
}

sub document_to_string {

	my $tree = shift;

	return join('', map { sprintf("<%s>%s</%s>", $_->[0], ref($_->[1]) eq 'ARRAY' ? document_to_string($_->[1]) : 1 ? '' : $_->[1], $_->[0]) } @$tree);
}

print_grammar($grammar);
print_document($tree);
