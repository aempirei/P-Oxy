#!/usr/bin/perl

use strict;
use warnings;

my $data = join('', <STDIN>);

my $dec = qr/(?:0|[1-9]\d*)/;
my $range = qr/\{(?:$dec,?|$dec,$dec|,$dec)\}/;
my $codes = qr/[[:alpha:]]|x[[:xdigit:]]{2}|0[0-7]{0,3}|\\|[1-9]\d?/;
my $sign = qr/(?:[+-]|\b)/;

my @tokens;

sub set {
	my ( $fmt, $type, $token ) = @_;
	print "type fail $token\n" unless (defined $token);
	return $type."\t".$token;
}

while(length($data) > 0) {

	my $token;

	if($data =~ /\A(\s+)/ms) {

		# whitespace is meaningless except to end greedy runs of tokens

	} elsif($data =~ /\A(##[^\n]*)$/ms) {

		# comment blobs are just parsed out in whole

		$token = set("%11s: %s\n", 'comment', $1);

	} elsif($data =~ /\A(\/(?:\\(?:\/|[*?|.+^\$\[\]{}]|$codes)|$range|[^\/])*\/(?:[ims]*\b)?)/) {
		
		# match
		$token = set("%11s: %s\n", 'match', $1);

	} elsif($data =~ /\A(\bs\/(?:\\(?:\/|[*?|.+^\$\[\]{}]|$codes)|$range|[^\/])*\/(?:\\(?:\/|$codes)|[^\/])*\/(?:[ims]*\b)?)/) {

		# subst
		$token = set("%11s: %s\n", 'subst', $1);

	} elsif($data =~ /\A([[:alpha:]_][[:alnum:]_]*[!?]*)/ms) {

		# name
		$token = set("%11s: %s\n", 'name', $1);

	} elsif($data =~ /\A(\.\.\.)/ms) {

		# root
		$token = set("%11s: %s\n", 'root', $1);

	} elsif($data =~ /\A(\.)/ms) {

		# dot
		$token = set("%11s: %s\n", 'dot', $1);

	} elsif($data =~ /\A('[^']*')/ms) {

		# literal
		$token = set("%11s: %s\n", 'literal', $1);

	} elsif($data =~ /\A("(?:\\(?:"|$codes)|[^"])*")/) {
		
		#quote
		$token = set("%11s: %s\n", 'quote', $1);

	} elsif($data =~ /\A([()])/ms) {

		# paren
		$token = set("%11s: %s\n", 'paren', $1);

	} elsif($data =~ /\A($sign$dec\.\d*[eE][+-]?$dec)\b/) {

		# float
		$token = set("%11s: %s\n", 'float', $1);

	} elsif($data =~ /\A($sign$dec\.(?:\d+\b)?)/) {

		# float
		$token = set("%11s: %s\n", 'float', $1);

	} elsif($data =~ /\A($sign$dec)\b/ms) {

		# decimal
		$token = set("%11s: %s\n", 'decimal', $1);

	} elsif($data =~ /\A(${sign}0[dD]\d+)\b/ms) {

		# decimal
		$token = set("%11s: %s\n", 'decimal', $1);

	} elsif($data =~ /\A(${sign}0[oO]?[0-7]+)\b/ms) {

		# octal
		$token = set("%11s: %s\n", 'octal', $1);

	} elsif($data =~ /\A(${sign}0[bB][01]+)\b/ms) {

		# binary
		$token = set("%11s: %s\n", 'binary', $1);

	} elsif($data =~ /\A(${sign}0[xX][[:xdigit:]]+)\b/ms) {

		# hexidecimal
		$token = set("%11s: %s\n", 'hexidecimal', $1);

	} elsif($data =~ /\A\b(true|false|null)\b/ms) {

		# boolean
		$token = set("%11s: %s\n", 'boolean', $1);

	} elsif($data =~ /\A([-^=+\[\]<>?\/\\,?:;*&~|%#~\`\$@!{}]+)/ms) {

		# operator
		$token = set("%11s: %s\n", 'operator', $1);

	} else {

		# failure
		print "failed match!\n";
		print $data;
		last;
	}

	push @tokens, $token if(defined $token);

	$data = $';
}

print join('', map { $_."\n" } @tokens);
