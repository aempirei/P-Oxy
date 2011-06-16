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

			# infix ops

	rule(:normal_op)		{ str('##').absnt? >> ops.repeat(1) }
	rule(:math_op)			{ match['\u2200-\u22ff'] }

			# prefix ops

	rule(:auto_op)			{ ( halfop >> dot >> halfterm ) }
	rule(:circum_op)		{ ( halfop >> star >> halfterm ) }

		# symbol pre-lexer rules

	rule(:func_symbol)	{ ( ( alpha | us ) >> ( alnum | us ).repeat >> ( bang | q? ).repeat ) }
	rule(:greek_symbol)	{ match['\u0300-\u03ff'] }

		# regexp pre-lexer rules

	rule(:sym)			{ match['*?|.+^$\[\]{}'] }
	rule(:code)			{ alpha | str('x') >> hex.repeat(2,2) | zero >> oct.repeat(0,3) | bs | fs | sym | tick | quote }

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

	rule(:unicode)			{ ( str('U+') >> hex.repeat(4,4) ).as(:unicode) >> space? }

	rule(:if_ctrl)			{ str('if').as(:if_ctrl) >> space? }
	rule(:then_ctrl)		{ str('then').as(:then_ctrl) >> space? }
	rule(:else_ctrl)		{ str('else').as(:else_ctrl) >> space? }
	rule(:elif_ctrl)		{ str('elif').as(:elif_ctrl) >> space? }
	rule(:is_ctrl)			{ str('is').as(:is_ctrl) >> space? }
	rule(:do_ctrl)			{ str('do').as(:do_ctrl) >> space? }
	rule(:wait_ctrl)		{ str('wait').as(:wait_ctrl) >> space? }
	rule(:each_ctrl)		{ str('each').as(:each_ctrl) >> rpace? }
	rule(:all_ctrl)		{ str('all').as(:all_ctrl) >> space? }
	rule(:while_ctrl)		{ str('while').as(:while_ctrl) >> space? }
	rule(:rescope_ctrl)	{ str('rescope').as(:rescope_ctrl) >> space? }

	rule(:symbol)			{ func_symbol | greek_symbol }
	
	rule(:base)				{ str('...') }

	rule(:single_qu)		{ ( tick >> match['^\''].repeat >> tick ).as(:single_qu) >> space? }
	rule(:double_qu)		{ ( quote >> ( code_expr | match['^"'] ).repeat >> quote ).as(:double_qu) >> space? } 

	rule(:integer_val)	{ ( sign.maybe >> ( binary | octal | decimal | hexidecimal ) ).as(:integer_val) >> space? }
	rule(:real_val)		{ float.as(:real_val) >> space? }
	rule(:boolean_val)	{ ( boolean_true | boolean_false | boolean_null ).as(:boolean_val) >> space? }

		# operators (prefix) -- aka symbols or operator nodes -- need to make more consistent descriptions

	rule(:prefix_op)		{ ( auto_op | circum_op ).as(:prefix_op) >> space? }

		# operators (infix)

	rule(:infix_op)		{ ( normal_op | math_op ).as(:infix_op) >> space? }

	# :op is just regular operators -- both prefix and infix, not special ops (list_op) or half-ops

	rule(:op)				{ infix_op | auto_op | circum_op }

		# half operators are circumfix operators applied as such

	rule(:half_op)			{ halfop.as(:half_op) >> space? }
	rule(:half_term)		{ halfterm.as(:half_term) >> space? }

		# list_op is a special operator / constructor

	rule(:list_op)			{ colon.as(:list_op) >> ops.absnt? >> space? }

	# WARNING: there may be issues with these

	rule(:left_bracket)	{ lb >> ops.absnt? >> space? }
	rule(:right_bracket)	{ rb >> ops.absnt? >> space? }
	rule(:left_arrow)		{ lt >> dash >> ops.absnt? >> space? }
	rule(:right_arrow)	{ dash >> gt >> ops.absnt? >> space? }
	rule(:free)				{ q?>> ops.absnt? >> space? }

	# parser rules

	rule(:nop)				{ space? >> eol }

		# link

	rule(:link)				{ ( node.as(:from) >> right_arrow >> node.as(:to) ).as(:link) >> space? } 

	rule(:node)				{ ( symbol_node | op_node | base ) >> space? }

	rule(:symbol_node)	{ path.maybe >> symbol }
	rule(:op_node)			{ path.maybe >> op }

	rule(:path)				{ base >> part.repeat | part.repeat(1) }

	rule(:part)				{ symbol >> dot }

		# assign
	
	rule(:assign)			{ list_assign | node_assign }

	rule(:node_assign)	{ node.as(:to) >> left_arrow >> expr.as(:from) }
	rule(:list_assign)	{ node.as(:head) >> list_op >> node.as(:tail) >> left_arrow >> expr.as(:from) }

		# each

	rule(:each)				{ str("unimplemented_replace") }

		# expr

	rule(:expr1)			{ call_expr | literal_expr | lambda_expr | cond_expr | all_expr | list_expr | do_expr | wait_expr }
	rule(:expr2)			{ lp >> expr >> rp }

	rule(:expr)				{ ( expr1 | expr2 ).as(:expr) >> space? }

	rule(:call_expr)		{ infix_call | prefix_call | circum_call }
	rule(:literal_expr)	{ string_literal | regexp_literal | numeric_literal }
	rule(:lambda_expr)	{ str("unimplemented_replace") }
	rule(:cond_expr)		{ str("unimplemented_replace") }
	rule(:all_expr)		{ str("unimplemented_replace") }
	rule(:list_expr)		{ str("left_recursion_breaker") >> param >> list_op >> param } # FIXME: left recursion problem
	rule(:do_expr)			{ str("unimplemented_replace") }
	rule(:wait_expr)		{ str("unimplemented_replace") }

			# literal_expr

	rule(:string_literal)	{ single_qu | double_qu | unicode }
	rule(:regexp_literal)	{ match_regexp | subst_regexp }
	rule(:numeric_literal)	{ integer_val | real_val | boolean_val }

			# call_expr

	rule(:infix_call)		{ str("left_recursion_breaker") >> param >> infix_op >> param } # FIXME: left recursion problem
	rule(:prefix_call)	{ node >> param.repeat }
	rule(:circum_call)	{ half_op >> param.repeat >> half_term }

	rule(:param)			{ expr | free } # FIXME: left recursion problem

		# command

	rule(:command)			{ space? >> ( link | assign | each | expr ).as(:command) >> terminator }

		# document

	rule(:document)		{ ( command | nop ).repeat(1) }

	root :document
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
