#!/usr/bin/env ruby

require 'rubygems'

require 'parslet'

class Mini < Parslet::Parser

	# whitespace rules

	rule(:space)		{ match('[ \t]').repeat(1) }
	rule(:space?)		{ space.maybe }

	# char rules

	rule(:bs)			{ str('\\') }
	rule(:fs)			{ str('/') }
	rule(:sc)			{ str(';') }
	rule(:comma)		{ str(',') }
	rule(:zero)			{ str('0') }
	rule(:lf)			{ str("\n") }
	rule(:cr)			{ str("\r") }

	# pre-lexer rules

		# numeric digit pre-lexer rules

	rule(:bin)			{ match['01'] }
	rule(:oct)			{ match['0-7'] }
	rule(:dec)			{ match['[:digit:]'] }
	rule(:hex)			{ match['[:xdigit:]'] }
	rule(:alpha)		{ match['[:alpha:]'] }
	rule(:sign)			{ match['-+'] }

		# complete number pre-lexer rules

	rule(:binary)			{ str('0b') >> bin.repeat(1) }
	rule(:decimal)			{ str('0d') >> dec.repeat(1) | zero | match['1-9'] >> dec.repeat }
	rule(:octal)			{ str('0o') >> oct.repeat(1) | zero >> oct.repeat(1) }
	rule(:hexidecimal)	{ str('0x') >> hex.repeat(1) }

		# op pre-lexer rules

	rule(:halfop)		{ str('<').repeat(2) | str('[').repeat(2) | str('{').repeat(2) }
	rule(:halfterm)	{ str('>').repeat(2) | str(']').repeat(2) | str('}').repeat(2) }

		# regexp pre-lexer rules

	rule(:sym)			{ match['*?|.+^$[]{}'] }
	rule(:code)			{ alpha | str('x') >> hex.repeat(2,2) | zero >> oct.repeat(0,3) | bs | fs | sym }

	rule(:range_expr)	{ str('{') >> ( decimal >> comma.maybe | decimal >> comma >> decimal | comma >> decimal ) >> str('}') }
	rule(:code_expr)		{ bs >> code }
	rule(:lit_expr)		{ match['^\\/'] }
	rule(:regexp)		{ ( code_expr | range_expr | lit_expr ).repeat }

	# lexer rules

	rule(:terminator)	{ sc | comment | eol }
	rule(:comment)		{ space? >> str('##') >> match('[^\n]').repeat.as(:comment) >> lf }
	rule(:eol)			{ space? >> lf }

	rule(:subst_regexp)	{ ( str('s/') >> regexp >> str('/') >> ( code_expr | lit_expr ).repeat >> str('/') >> match['imsg'].repeat ).as(:subst_regexp) >> space? }
	rule(:match_regexp)	{ ( str('/') >> regexp >> str('/') >> match['ims'].repeat ).as(:match_regexp) >> space? }

	rule(:unicode_expr)	{ str('U+') >> hex.repeat(4,4) >> space? }

	rule(:if_ctrl) { str('if').as(:if_ctrl) >> space? }
	rule(:then_ctrl) { str('then').as(:then_ctrl) >> space? }
	rule(:else_ctrl) { str('else').as(:else_ctrl) >> space? }
	rule(:elif_ctrl) { str('elif').as(:elif_ctrl) >> space? }
	rule(:is_ctrl) { str('is').as(:is_ctrl) >> space? }
	rule(:do_ctrl) { str('do').as(:do_ctrl) >> space? }
	rule(:wait_ctrl) { str('wait').as(:wait_ctrl) >> space? }
	rule(:each_ctrl) { str('each').as(:each_ctrl) >> space? }
	rule(:all_ctrl) { str('all').as(:all_ctrl) >> space? }
	rule(:while_ctrl) { str('while').as(:while_ctrl) >> space? }
	rule(:rescope_ctrl) { str('rescope').as(:rescope_ctrl) >> space? }

	# Single character rules
#	rule(:lparen)		{ str('(') >> space? }
#	rule(:rparen)		{ str(')') >> space? }
#	rule(:infixop)		{ match('[+*-/]').as(:infixop) >> space? }

	# Things
#	rule(:integer)		{ match('[0-9]').repeat(1).as(:integer) >> space? }

	# Grammar parts
#	rule(:block)		{ lparen >> expression >> rparen }
#	rule(:value)		{ block | integer }

#	rule(:infixcall)	{ value.as(:left) >> infixop >> expression.as(:right) }
#	rule(:expression)	{ infixcall | value }

	rule(:command)		{ space? >> ( match_regexp | subst_regexp ) >> terminator }

	rule(:expression)	{ ( command | comment | eol ).repeat(1) }
	root :expression
end

input = STDIN.read

puts "parsing '#{input}'"

p Mini.new.parse(input)

=begin

class IntLit < Struct.new(:int)
	def eval
		int.to_i
	end
end

class Addition < Struct.new(:left, :right) 
	def eval
		left.eval + right.eval
	end
end

class MiniT < Parslet::Transform
	rule(:int => simple(:int))                                          { IntLit.new(int) }
	rule(:left => simple(:left), :right => simple(:right), :op => '+')  { Addition.new(left, right) }
end

parser = MiniP.new
transf = MiniT.new



ast = transf.apply(parser.parse('  puts ( 2+2 +1+1 +2 + 3 , puts(1),1 + 1,puts ( 1,2 , 3), 3 )  '))

ast.eval

=end
