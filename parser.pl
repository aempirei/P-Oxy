#!/usr/bin/perl
#
# Parser Tester for The P Programming Language
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
use Getopt::Long;

if(scalar(@ARGV) != 2) {
	print STDERR "\nusage: $0 grammar program\n\n";
	exit;
}

my ( $grammar_filename, $program_filename ) = @ARGV;

my $program_fh = IO::File::new;
my $grammar_fh = IO::File::new;

$grammar_fh->open('<'.$grammar_filename) or die "could not open grammar file $grammar_filename";
$program_fh->open('<'.$program_filename) or die "could not open program file $program_filename";

#
# one grammar rule per line (but some grammar rules are combined via '|' (logical OR)
#

my $program_data = join('', <$program_fh>);
my $grammar_data = join('', <$grammar_fh>);

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
	print '<?xml version="1.0"?><program>'.document_to_string($document)."</program>\n";
}

sub document_to_string {

	my $tree = shift;

	return join('', map { sprintf("<%s>%s</%s>", $_->[0], ref($_->[1]) eq 'ARRAY' ? document_to_string($_->[1]) : 1 ? '' : $_->[1], $_->[0]) } @$tree);
}

print_grammar($grammar);
print_document($tree);
