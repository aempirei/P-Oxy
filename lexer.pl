#!/usr/bin/perl
#
# Lexer Tester for The P Programming Language
#
# Copyright(c) 2010 by Christopher Abad
# aempirei@gmail.com
#

use lib './lib';

use strict;
use warnings;
use P::Lexer;

my $data = join('', <STDIN>);

my $tokens = P::Lexer::get_tokens($data);

foreach my $tt (@$tokens) {
	my ($type, $token) = @$tt;
	printf("%15s %-15s\n", $type, $token);
}
