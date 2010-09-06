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

my $grammar = P::Parser::get_grammar($grammar_data);
my $tokens = P::Lexer::get_tokens($program_data);

#
# dump out the parsed grammar spec.
#

sub print_grammar {

	my $grammar = shift;

	my ( $rules, $prefixes ) = @$grammar;

	foreach my $prefix (@$prefixes) {
		my $rule = join(' ', @$prefix);
		die "rule not found: $rule" unless(exists $rules->{$rule});
		printf("%s := %s\n", $rule, join(' | ', keys(%{$rules->{$rule}})));
	}
}

sub print_document {

	my $document = shift;

	foreach my $node (@$document) {
		my ( $type, $token ) = @$node;

		print "<$type:$token>\n";
	}

}

sub get_all_substitutions {

	my ( $document, $grammar ) = @_;

	my $subs = [];

	push @$subs, [ [ 'document', $document ] ];

	return $subs;
}

# each node is of the form [ type, [ nodes... ] OR token ]
# each document is of the form  [ nodes... ]
# $tokens pretty much is a sequence of nodes already
# the minimal tree doument would look something like [ [ 'document' , [ ] ] ]

sub get_tree {
	my ( $document, $grammar ) = @_;

	my $first_node = $document->[0];

	my ( $first_type, $first_token ) = @$first_node;

	print STDERR sprintf("document size: %s first node type: %s\n", scalar(@$document), $first_type);

	if(scalar(@$document) == 1 and $first_type eq 'document') {

		return $document;

	} else {

		my $all_substitutions = get_all_substitutions($document, $grammar);

		foreach my $subst_document (@$all_substitutions) {

			my $tree = get_tree($subst_document, $grammar);

			return $tree if(defined $tree);
		}
	}
}

sub document_to_string {

	my $tree = shift;

	return join('', map { sprintf("<%s>%s</%s>", $_->[0], ref($_->[1]) eq 'ARRAY' ? document_to_string($_->[1]) : 1 ? '' : $_->[1], $_->[0]) } @$tree);
}

# print_grammar($grammar);
# print_document($tokens);

my $tree = get_tree($tokens, $grammar);

print '<?xml version="1.0"?><source>'.document_to_string($tree)."</source>\n";
