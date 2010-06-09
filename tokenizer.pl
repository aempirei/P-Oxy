#!/usr/bin/perl
#
# Lexical Analyzer for The P Programming Language
#
# Copyright(c) 2010 by Christopher Abad
# aempirei@gmail.com
#

use lib './lib';

use strict;
use warnings;
use P::Lexer;

my $data = join('', <STDIN>);

my @tokens;

while(length($data) > 0) {
	my ( $type, $token, $tail ) = P::Lexer::get_type_token_tail($data);
	print "parsed token : $type -- $token\n";
	push @tokens, [ $type, $token ];
	$data = $tail;
}
