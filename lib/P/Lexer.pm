#
# Lexical Analyzer for The P Programming Language
#
# Copyright(c) 2010 by Christopher Abad
# aempirei@gmail.com
#

package P::Lexer;

use strict;
use warnings;

use Encode;

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
my $space = qr/(?:[ \t\r]|\\\n)/;
my $halfop = qr/(?:<<+|\[+|\{\{+)/;
my $halfterm = qr/(?:>>+|\]+|\}\}+)/;

#
# this the the main lexing function, returning the triple : ( type, token, tail )
#

sub get_tokens {

	my $data = decode_utf8(shift);

	my $tokens = [];

	my $offset = 0;

	while(length($data) > 0) {
	    my ( $type, $token, $tail ) = get_type_token_tail($data);
	    push @$tokens, [ $type, encode_utf8($token), $offset, $offset ];
		$offset += 1;
		$data = $tail;
	}

	return $tokens;
}

sub get_type_token_tail {

	my $type;
	my $token;

	my $data = shift;

	# non-newline whitespace is meaningless -- consume it

	$data =~ s/\A$space+//ms;

	# match the next token. these regular expressions are sorted with longest
	# running tokens first in the case of tokens that are potential prefixes
	# such as the case of the symbol token 's' being the prefix to the
	# substitution token s/// for example.

	if($data =~ /\A(\n(?:$space|\n)*)/ms) {

		# newline -- newline is 'interesting' because its used as a parameter
		# termination code along with ) and } and keywords and generally anything
		# that can't be interpreted as a parameter.
		# newlines can be forced as whitespace by escaping them like so: \
		( $type, $token ) = ('newline', '');

	} elsif($data =~ /\A(##[^\n]*)$/ms) {

		# comment blobs are just parsed out in whole but not including their newline
		( $type, $token ) = ('comment', $1);

	} elsif($data =~ /\A(\/(?:\\(?:\/|[*?|.+^\$\[\]{}]|$codes)|$range|[^\/])*\/(?:[ims]*\b)?)/ms) {
	
		# match-regexp
		( $type, $token ) = ('match-regexp', $1);

	} elsif($data =~ /\A(\bs\/(?:\\(?:\/|[*?|.+^\$\[\]{}]|$codes)|$range|[^\/])*\/(?:\\(?:\/|$codes)|[^\/])*\/(?:[imsg]*\b)?)/ms) {

		# subst-regexp
		( $type, $token ) = ('subst-regexp', $1);

	} elsif($data =~ /\A(U\+[[:xdigit:]]{4}\b)/ms) {

		# unicode-expr
		( $type, $token ) = ('unicode-expr', $1);

	} elsif($data =~ /\A([[:alpha:]_][[:alnum:]_]*[!?]*)/ms) {

		# symbols

		my @keywords = qw(if then else elif is do wait each all while rescope);

		$token = $1;

		if(grep(/^\Q$token\E$/, @keywords)) {
			$type = $token.'-op';
		} else {
			$type = 'symbol';
		}

	} elsif($data =~ /\A([\x{300}-\x{3ff}])/ms) {

		# single greek letter
		( $type, $token ) = ('symbol', $1);

	} elsif($data =~ /\A(\.\.\.)/ms) {

		# root
		( $type, $token ) = ('root', $1);

	} elsif($data =~ /\A(\.)/ms) {

		# dot
		( $type, $token ) = ('dot', $1);

	} elsif($data =~ /\A('[^']*')/ms) {

		# single-quoted
		( $type, $token ) = ('single-quoted', $1);

	} elsif($data =~ /\A("(?:\\(?:"|$codes)|[^"])*")/ms) {

		# double-quoted
		( $type, $token ) = ('double-quoted', $1);

	} elsif($data =~ /\A(\()/ms) {

		( $type, $token ) = ('left-paren', $1);

	} elsif($data =~ /\A(\))/ms) {

		( $type, $token ) = ('right-paren', $1);

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

	} elsif($data =~ /\A($halfop\.$halfterm)/ms) {

		# auto circumfix operator
		( $type, $token ) = ('auto-circumfix-operator', $1);

	} elsif($data =~ /\A($halfop\*$halfterm)/ms) {

		# circumfix operator
		( $type, $token ) = ('circumfix-operator', $1);

	} elsif($data =~ /\A($halfop)/ms) {

		# half operator
		( $type, $token ) = ('half-operator', $1);

	} elsif($data =~ /\A($halfterm)/ms) {

		# half terminator
		( $type, $token ) = ('half-terminator', $1);

	} elsif($data =~ /\A([-^=+\[\]<>?\/\\,?:;*&~|%#~\`\$@!{}]+)/ms) {

		# operators

		my %operators = (
			'{'  => 'left-bracket',
			'}'  => 'right-bracket',
			'<-' => 'left-arrow',
			'->' => 'right-arrow',
			'?'  => 'free',
			':'  => 'list-op',
			';'  => 'semicolon'
		);

		$token = $1;

		if(exists $operators{$token}) {
			$type = $operators{$token};
		} else {
			$type = 'normal-operator';
		}

	} elsif($data =~ /\A([\x{2200}-\x{22ff}])/ms) {

		# single math operator
		( $type, $token ) = ('normal-operator', $1);

	} elsif($data =~ /\A(.*)$/ms) {

		# failure
		( $type, $token ) = ( 'error', $1 );
	}

	return ( $type, $token, $' );
}

END { }

1;
