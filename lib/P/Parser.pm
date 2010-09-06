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

	foreach my $node (keys(%$rule)) {
		my $new_document = [ @$document[0..$offset,($offset+$length)..$#$document] ];
		$new_document->[$offset] = [ $node, [ @$document[$offset..($offset+$length-1)] ] ];

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

	foreach my $prefix (@{$grammar->[1]}) {
		foreach my $offset (0..$#$document) {
			if(prefix_matches($document, $offset, $prefix)) {
				push @$subs, get_substitution($document, $offset, $prefix, $grammar);
			}
		}
	}

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

	if(scalar(@$document) == 1 and $first_type eq 'document') {

		return $document;

	} else {

		my $all_substitutions = get_all_substitutions($document, $grammar);

		foreach my $subst_document (@$all_substitutions) {

			print join(' ', map { $_->[0] } @$subst_document)."\n";

			my $tree = get_tree($subst_document, $grammar);

			return $tree if(defined $tree);
		}
	}

	return;
}

END { }

1;
