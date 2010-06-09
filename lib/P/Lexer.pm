#
# Lexical Analyzer for The P Programming Language
#
# Copyright(c) 2010 by Christopher Abad
# aempirei@gmail.com
#

package P::Lexer;

use strict;
use warnings;


BEGIN {
	use Exporter ();
	our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

	$VERSION = 1.00;

	@ISA = qw(Exporter);
	@EXPORT = qw(&get_type_token_tail);
	%EXPORT_TAGS = ( );

	@EXPORT_OK = qw();
}

our @EXPORT_OK;

#
# some common regexp patterns
#

my $dec = qr/(?:0|[1-9]\d*)/;
my $range = qr/\{(?:$dec,?|$dec,$dec|,$dec)\}/;
my $codes = qr/[[:alpha:]]|x[[:xdigit:]]{2}|0[0-7]{0,3}|\\|[1-9]\d?/;
my $sign = qr/(?:[+-]|\b)/;

#
# this the the main lexing function, returning the triple : ( type, token, tail )
#

sub get_type_token_tail {

	my $type;
	my $token;

	my $data = shift;

	# whitespace is meaningless -- consume it

	$data =~ s/\A(\s+)//;

	# match the next token. these regular expressions are sorted with longest
	# running tokens first in the case of tokens that are potential prefixes
	# such as the case of the symbol token 's' being the prefix to the
	# substitution token s/// for example.

	if($data =~ /\A(##[^\n]*)$/ms) {

		# comment blobs are just parsed out in whole
		( $type, $token ) = ('comment', $1);

	} elsif($data =~ /\A(\/(?:\\(?:\/|[*?|.+^\$\[\]{}]|$codes)|$range|[^\/])*\/(?:[ims]*\b)?)/ms) {
	
		# match
		( $type, $token ) = ('match', $1);

	} elsif($data =~ /\A(\bs\/(?:\\(?:\/|[*?|.+^\$\[\]{}]|$codes)|$range|[^\/])*\/(?:\\(?:\/|$codes)|[^\/])*\/(?:[imsg]*\b)?)/ms) {

		# subst
		( $type, $token ) = ('subst', $1);

	} elsif($data =~ /\A([[:alpha:]_][[:alnum:]_]*[!?]*)/ms) {

		# symbol
		( $type, $token ) = ('symbol', $1);

	} elsif($data =~ /\A(\.\.\.)/ms) {

		# root
		( $type, $token ) = ('root', $1);

	} elsif($data =~ /\A(\.)/ms) {

		# dot
		( $type, $token ) = ('dot', $1);

	} elsif($data =~ /\A('[^']*')/ms) {

		# literal
		( $type, $token ) = ('literal', $1);

	} elsif($data =~ /\A("(?:\\(?:"|$codes)|[^"])*")/ms) {

		#quote
		( $type, $token ) = ('quote', $1);

	} elsif($data =~ /\A([()])/ms) {

		# paren
		( $type, $token ) = ('paren', $1);

	} elsif($data =~ /\A($sign$dec\.\d*[eE][+-]?$dec)\b/ms) {

		# float
		( $type, $token ) = ('float', $1);

	} elsif($data =~ /\A($sign$dec\.(?:\d+\b)?)/ms) {

		# float
		( $type, $token ) = ('float', $1);

	} elsif($data =~ /\A($sign$dec)\b/ms) {

		# decimal
		( $type, $token ) = ('decimal', $1);

	} elsif($data =~ /\A(${sign}0[dD]\d+)\b/ms) {

		# decimal
		( $type, $token ) = ('decimal', $1);

	} elsif($data =~ /\A(${sign}0[oO]?[0-7]+)\b/ms) {

		# octal
		( $type, $token ) = ('octal', $1);

	} elsif($data =~ /\A(${sign}0[bB][01]+)\b/ms) {

		# binary
		( $type, $token ) = ('binary', $1);

	} elsif($data =~ /\A(${sign}0[xX][[:xdigit:]]+)\b/ms) {

		# hexidecimal
		( $type, $token ) = ('hexidecimal', $1);

	} elsif($data =~ /\A\b(true|false|null)\b/ms) {

		# boolean
		( $type, $token ) = ('boolean', $1);

	} elsif($data =~ /\A([-^=+\[\]<>?\/\\,?:;*&~|%#~\`\$@!{}]+)/ms) {

		# operator
		( $type, $token ) = ('operator', $1);

	} elsif($data =~ /\A(.*)$/ms) {

		# failure
		( $type, $token ) = ( 'error', $1 );
	}

	return ( $type, $token, $' );
}

END { }

1;
