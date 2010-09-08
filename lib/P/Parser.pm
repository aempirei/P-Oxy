#
# Source Parser for The P Programming Language
#
# Copyright(c) 2010 by Christopher Abad
# aempirei@gmail.com
#

use lib '..';

package P::Parser;

use strict;
use warnings;
use P::Grammar;

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

# apply $prefix from $grammar->[0]->{join('', @$prefix)} to $document->[$offset]

sub get_substitution {

	my ( $document, $offset, $prefix, $grammar ) = @_;

	my $length = scalar(@$prefix);

	die "prefix extends past end of document" if($offset + $length > scalar(@$document));

	my $sub_document = [ @$document[$offset..($offset+$length-1)] ];

	my ( $rules, $prefixes ) = @$grammar;

	my @new_documents;

	my $rule = $rules->{P::Grammar::prefix_to_key($prefix)};

	foreach my $node_type (sort { $rule->{$a} <=> $rule->{$b} } keys(%$rule)) {

		my $new_document = [ @$document[0..$offset,($offset+$length)..$#$document] ];

		my $new_node = [ $node_type, $sub_document, $sub_document->[0]->[2], $sub_document->[$#$sub_document]->[3] ];

		$new_document->[$offset] = $new_node;

		push @new_documents, $new_document;
	}

	return @new_documents;
}

# check if $prefix matches document at $document->[$offset]

sub prefix_matches {

	my ( $document, $offset, $prefix ) = @_;

	my $length = scalar(@$prefix);

	return 0 if($offset + $length > scalar(@$document));

	my $sub_document = [ map { $_->[0] } @$document[$offset..($offset+$length-1)] ];

	my $s = P::Grammar::prefix_to_key($prefix);
	my $t = P::Grammar::prefix_to_key($sub_document);

	return ($s eq $t);
}

# get every simple substitution that exists for the given document

sub get_all_substitutions {

	my ( $document, $grammar ) = @_;

	my $subs = [];

	# push @$subs, [ [ 'document', $document ] ];

	# the order that the substitutions are iterated through affects performance
	# the grammar rules that are the lowest in the grammar dictionary should be applied first

	foreach my $offset (0..$#$document) {
		foreach my $prefix (@{$grammar->[1]}) {
			if(prefix_matches($document, $offset, $prefix)) {
				push @$subs, get_substitution($document, $offset, $prefix, $grammar);
			}
		}
	}

	return $subs;
}

sub node_to_key {
	my $node = shift;
	return sprintf('%s[%d-%d]', $node->[0], $node->[2], $node->[3]);
}

# each node is of the form [ type, [ nodes... ] OR token ]
# each document is of the form  [ nodes... ]
# $tokens pretty much is a sequence of nodes already
# the minimal tree doument would look something like [ [ 'document' , [ ] ] ]

sub get_tree {
	my ( $document, $grammar ) = @_;

	my $first_node = $document->[0];

	my ( $first_type, $first_token ) = @$first_node;

	print join(' ', map { node_to_key($_) } @$document)."\n";
			
	if(scalar(@$document) == 1 and $first_type eq 'document') {

		return $document;

	} else {

		my $all_substitutions = get_all_substitutions($document, $grammar);

		foreach my $subst_document (@$all_substitutions) {

			my $tree = get_tree($subst_document, $grammar);

			return $tree if(defined $tree);
		}
	}

	return;
}

sub get_command {

	my ( $document, $grammar ) = @_;

	my $first_node = $document->[0];

	my ( $first_type, $first_token ) = @$first_node;

	if($first_type eq 'full_command') {

		return $first_node;

	} else {

		my $all_substitutions = get_all_substitutions($document, $grammar);

		foreach my $subst_document (@$all_substitutions) {

			my $command = get_command($subst_document, $grammar);

			return $command if(defined $command);
		}
	}

	return;
}

END { }

1;
