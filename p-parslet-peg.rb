#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'parslet'
require 'unicode'

class Mini < Parslet::Parser

	# whitespace rules

	rule(:space)		{ match('[ \t]').repeat(1) }
	rule(:space?)		{ space.maybe }

	# char rules

	rule(:lf)			{ str("\n") }
	rule(:cr)			{ str("\r") }
	rule(:bs)			{ str('\\') }
	rule(:tick)			{ str('\'') }
	rule(:quote)		{ str('"') }
	rule(:comma)		{ str(',') }
	rule(:zero)			{ str('0') }
	rule(:bang)			{ str('!') }
	rule(:dash)			{ str('-') }
	rule(:star)			{ str('*') }
	rule(:dot)			{ str('.') }
	rule(:eq)			{ str('=') }
	rule(:fs)			{ str('/') }
	rule(:sc)			{ str(';') }
	rule(:us)			{ str('_') }
	rule(:lp)			{ str('(') }
	rule(:rp)			{ str(')') }
	rule(:q?)			{ str('?') }
	rule(:colon)		{ str(':') }
	rule(:lt)			{ str('<') }
	rule(:gt)			{ str('>') }
	rule(:ls)			{ str('[') }
	rule(:rs)			{ str(']') }
	rule(:lb)			{ str('{') }
	rule(:rb)			{ str('}') }

	#
	# pre-lexer rules
	#

		# numeric digit pre-lexer rules

	rule(:bin)			{ match['01'] }
	rule(:oct)			{ match['0-7'] }
	rule(:dec)			{ match['[:digit:]'] }
	rule(:hex)			{ match['[:xdigit:]'] }
	rule(:alpha)		{ match['[:alpha:]'] }
	rule(:alnum)		{ match['[:alnum:]'] }
	rule(:nonzero)		{ match['1-9'] }
	rule(:sign)			{ match['-+'] }
	rule(:ops)			{ match['-^=+\[\]<>?\/\\,?:;*&~|%#~\`\$@!{}'] }

		# complete number pre-lexer rules

	rule(:decimal0)		{ zero | nonzero >> dec.repeat }
	rule(:decimal1)		{ zero >> match['Dd'] >> dec.repeat(1) }
	rule(:decimal2)		{ nonzero >> dec.repeat >> dot.absnt? }
	rule(:decimal3)		{ zero >> match['DdBbOoXx.'].absnt? }

	rule(:decimal)			{ decimal1 | decimal2 | decimal3 } 

	rule(:binary)			{ zero >> match['Bb'] >> bin.repeat(1) }
	rule(:octal)			{ zero >> match['Oo'] >> oct.repeat(1) | zero >> oct.repeat(1) }
	rule(:hexidecimal)	{ zero >> match['Xx'] >> hex.repeat(1) }

	rule(:float)			{ sign.maybe >> decimal0 >> dot >> dec.repeat >> ( match['eE'] >> sign.maybe >> decimal0 ).maybe }

	rule(:boolean_true)	{ match['tT'] >> match['rR'] >> match['uU'] >> match['eE'] }
	rule(:boolean_false)	{ match['fF'] >> match['aA'] >> match['lL'] >> match['sS'] >> match['eE'] }
	rule(:boolean_null)	{ match['nN'] >> match['uU'] >> match['lL'] >> match['lL'] }

		# op pre-lexer rules

	rule(:halfop)		{ lt.repeat(2) | ls.repeat(2) | lb.repeat(2) }
	rule(:halfterm)	{ gt.repeat(2) | rs.repeat(2) | rb.repeat(2) }

		# regexp pre-lexer rules

	rule(:sym)			{ match['*?|.+^$[]{}'] }
	rule(:code)			{ alpha | str('x') >> hex.repeat(2,2) | zero >> oct.repeat(0,3) | bs | fs | sym }

	rule(:range_expr)	{ lb >> ( decimal >> comma.maybe | decimal >> comma >> decimal | comma >> decimal ) >> rb }
	rule(:code_expr)	{ bs >> code }
	rule(:lit_expr)	{ match['^\\/'] }
	rule(:regexp)		{ ( code_expr | range_expr | lit_expr ).repeat }

	#
	# lexer rules
	#

	rule(:comment)		{ str('##') >> ( str('e') | match['^\n'] ).repeat }
	rule(:eol)			{ comment.maybe >> lf }
	rule(:terminator)		{ sc | eol }

	rule(:subst_regexp)	{ ( str('s/') >> regexp >> fs >> ( code_expr | lit_expr ).repeat >> fs >> match['imsg'].repeat ).as(:subst_regexp) >> space? }
	rule(:match_regexp)	{ ( fs >> regexp >> fs >> match['ims'].repeat ).as(:match_regexp) >> space? }

	rule(:unicode_expr)	{ ( str('U+') >> hex.repeat(4,4) ).as(:unicode_expr) >> space? }

	rule(:if_ctrl)			{ str('if').as(:if_ctrl) >> space? }
	rule(:then_ctrl)		{ str('then').as(:then_ctrl) >> space? }
	rule(:else_ctrl)		{ str('else').as(:else_ctrl) >> space? }
	rule(:elif_ctrl)		{ str('elif').as(:elif_ctrl) >> space? }
	rule(:is_ctrl)			{ str('is').as(:is_ctrl) >> space? }
	rule(:do_ctrl)			{ str('do').as(:do_ctrl) >> space? }
	rule(:wait_ctrl)		{ str('wait').as(:wait_ctrl) >> space? }
	rule(:each_ctrl)		{ str('each').as(:each_ctrl) >> space? }
	rule(:all_ctrl)		{ str('all').as(:all_ctrl) >> space? }
	rule(:while_ctrl)		{ str('while').as(:while_ctrl) >> space? }
	rule(:rescope_ctrl)	{ str('rescope').as(:rescope_ctrl) >> space? }

	rule(:func_symbol)	{ ( ( alpha | us ) >> ( alnum | us ).repeat >> ( bang | q? ).repeat ).as(:symbol) }
	rule(:greek_symbol)	{ match['\u0300-\u03ff'] }
	
	rule(:symbol)			{ ( func_symbol | greek_symbol ).as(:symbol) >> space? }
	
	rule(:base)				{ str('...').as(:base) >> space? }

	rule(:single_qu)		{ tick >> match['^\''].repeat >> tick >> space? }
	rule(:double_qu)		{ quote >> ( code_expr | match['^"'] ).repeat >> quote >> space? } 

	rule(:integer)			{ ( sign.maybe >> ( binary | octal | decimal | hexidecimal ) ).as(:integer) >> space? }
	rule(:real)				{ float.as(:real) >> space? }
	rule(:boolean)			{ ( boolean_true | boolean_false | boolean_null ).as(:boolean) >> space? }

	rule(:auto_op)			{ ( halfop >> dot >> halfterm ).as(:auto_op) >> space? }
	rule(:circum_op)		{ ( halfop >> star >> halfterm ).as(:circum_op) >> space? }

	rule(:half_op)			{ halfop.as(:half_op) >> space? }
	rule(:half_term)		{ halfterm.as(:half_term) >> space? }

	# WARNING: there may be issues with these

	rule(:left_bracket)	{ str('{').as(:left_bracket) >> ops.absnt? >> space? }
	rule(:right_bracket)	{ str('}').as(:right_bracket) >> ops.absnt? >> space? }
	rule(:left_arrow)		{ str('<-').as(:left_arrow) >> ops.absnt? >> space? }
	rule(:right_arrow)	{ str('->').as(:right_arrow) >> ops.absnt? >> space? }
	rule(:free)				{ q?.as(:free) >> ops.absnt? >> space? }
	rule(:list_op)			{ colon.as(:list_op) >> ops.absnt? >> space? }
	rule(:normal_op)		{ ops.repeat(1).as(:normal_op) >> space? }

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

	rule(:command)		{ space? >> ( match_regexp | subst_regexp | real | integer | boolean | symbol ) >> terminator }
	rule(:nop)			{ space? >> eol }

	rule(:expression)	{ ( command | nop ).repeat(1) }
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
