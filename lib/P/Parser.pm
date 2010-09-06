#
# Source Parser for The P Programming Language
#
# Copyright(c) 2010 by Christopher Abad
# aempirei@gmail.com
#

package P::Parser;

use strict;
use warnings;


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
	my ( $document, $Offset, $prefix, $grammar ) = @_;
}

# check if $prefix matches document at $document->[$offset]

sub prefix_matches {
	my ( $document, $offset, $prefix ) = @_;

	return 0;
}

# get every simple substitution that exists for the given document

sub get_all_substitutions {

	my ( $document, $grammar ) = @_;

	my $subs = [];

	push @$subs, [ [ 'document', $document ] ];

	foreach my $prefix (@{$grammar->[1]}) {
		foreach my $offset (0..$#$document) {
			if(prefix_matches($document, $offset, $prefix, $grammar)) {
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

END { }

1;
