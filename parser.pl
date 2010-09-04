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

sub grammar_error {
	my $document = shift;
	print "grammar error in parsing source code\n";
}

sub replace_sub {

	my ( $document, $from, $to ) = @_;

	print "next replacement is $from -> $to\n";

	exit;
}
exit;

sub get_next_sub {

	my $document = shift;

	my $i = 0;

	while($i < scalar(@$document)) {
	
		print "testing offset $i\n";


foreach my $rule (keys(%grammar)) {
	printf("%s := %s\n", $rule, join(' | ', keys(%{$grammar{$rule}})));
}


		foreach my $rule (keys(%grammar)) {
		}

		# for each offset into the document
			# for each prefix rule
				# if prefix rule matches
					# save prefix rule
			# if there are matches
				# return the longest prefix match

		$i += 1;
	}

	# if we get to this point and no substitution was found then the document contains a grammar error.
	# just return nothing right now, but eventually the grammar error should be identified as close to
	# the syntax mistake as possible.

	return;
}

my @expr;

my $document = [@tokens];

while(scalar(@$document) > 1 and $document->[0]->[0] ne 'document') {

	# until primary sequence is <document>

	my @sub = get_next_sub($document);

	if(scalar(@sub) > 0) {

		# if a compressable substitution exists, then perform the replacement

		my ( $from, $to ) = @sub;
		$document = replace_sub($document, $from, $to);

	} else {

		# if one wasnt found then there is an error in the grammar

		grammar_error();
		exit;
	}
}

# if document is 'document'
	# then return

# for each possible substitution
	# attempt substitution
	# if recurse is 'document'
		# then return

# return error

