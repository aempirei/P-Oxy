#!/usr/bin/env ruby

require 'rubygems'

require 'parslet'

class Mini < Parslet::Parser

	# whitespace rules

	rule(:ws)			{ match('\s').repeat(1) }
	rule(:ws?)			{ ws.maybe }

	rule(:space)		{ match('[ \t]').repeat(1) }
	rule(:space?)		{ space.maybe }

	rule(:nl)			{ match('[\n\r]').repeat(1) >> ws? }

	# char rules

	rule(:bs)			{ str('\\') }
	rule(:fs)			{ str('/') }

	# pre-lexer rules

	rule(:comma)		{ str(',') }
	rule(:zero)			{ str('0') }

	rule(:hex)			{ match['[:xdigit:]'] }
	rule(:dec)			{ match['\d'] }
	rule(:oct)			{ match['0-7'] }
	rule(:bin)			{ match['01'] }
	rule(:alpha)		{ match['[:alpha:]'] }
	rule(:sym)			{ match['*?|.+^$[]{}'] }

	rule(:decimal)		{ zero | match['1-9'] >> dec.repeat }

	# lexer rules

	rule(:semicolon)	{ str(';') >> ws? }

	rule(:terminator)	{ semicolon | nl }

	rule(:comment)		{ ws? >> ( str('##') >> match('[^\n]').repeat ).as(:comment) >> nl }

	rule(:sign)			{ match['-+'] }
	rule(:halfop)		{ str('<').repeat(2) | str('[').repeat(2) | str('{').repeat(2) }
	rule(:halfterm)	{ str('>').repeat(2) | str(']').repeat(2) | str('}').repeat(2) }
	rule(:codes)		{ alpha | str('x') >> hex.repeat(2,2) | str('0') >> oct.repeat(0,3) | str('\\') }

	# string rules

	rule(:litexp)		{ match['^\\/'] }
	rule(:rangeexp)	{ str('{') >> ( decimal >> comma.maybe | decimal >> comma >> decimal | comma >> decimal ) >> str('}') }
	rule(:codeexp)		{ str('\\') >> ( str('/') | sym | codes ) }

	rule(:regexp)		{ ( codeexp | rangeexp | litexp ).repeat }

	rule(:substregexp) { ( str('s/') >> regexp >> str('/') >> ( codeexp | litexp ).repeat >> str('/') >> match['imsg'].repeat ).as(:substregexp) >> space? }
	rule(:matchregexp) { ( str('/') >> regexp >> str('/') >> match['ims'].repeat ).as(:matchregexp) >> space? }

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

	rule(:expression)	{ ( comment | ( matchregexp | substregexp ) >> nl.maybe ).repeat }
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
