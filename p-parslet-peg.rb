#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'parslet'
require 'unicode'

class Mini < Parslet::Parser

	# whitespace rules

	rule(:space)		{ ( match('[ \t]') | bs >> lf ).repeat(1) }
	rule(:space?)		{ space.maybe }

	# char rules

	rule(:lf)			{ str("\n") }
	rule(:cr)			{ str("\r") }
	rule(:bs)			{ str("\\") }
	rule(:tick)			{ str("\'") }
	rule(:quote)		{ str("\"") }
	rule(:comma)		{ str(',') }
	rule(:zero)			{ str('0') }
	rule(:bang)			{ str('!') }
	rule(:dash)			{ str('-') }
	rule(:star)			{ str('*') }
	rule(:pipe)			{ str('|') }
	rule(:dot)			{ str('.') }
	rule(:eq)			{ str('=') }
	rule(:fs)			{ str('/') }
	rule(:sc)			{ str(';') }
	rule(:us)			{ str('_') }
	rule(:lp)			{ str('(') }
	rule(:rp)			{ str(')') }
	rule(:q?)			{ str('?') }
	rule(:colon)		{ str(':') }
	rule(:dollar)		{ str('$') }
	rule(:at)			{ str('@') }
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
	rule(:ops)			{ aux_ops | required_ops }
	rule(:aux_ops)			{ match['$@!?'] }
	rule(:required_ops)	{ match['-^=+<>\/\\,:*&~|%#~\`'] }

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

	rule(:halfop)		{ ls.repeat(1) | lb.repeat(2) }
	rule(:halfterm)	{ rs.repeat(1) | rb.repeat(2) }

	rule(:special_ops)	{ comment_op | left_arrow | right_arrow | free }

	rule(:comment_op)		{ str('##') }

		# special operators

	rule(:list_op)			{ colon }
	rule(:left_arrow)		{ lt >> dash }
	rule(:right_arrow)	{ dash >> gt }
	rule(:free)				{ q? }

			# infix ops

	rule(:normal_op1)		{ required_ops >> ops.repeat }
	rule(:normal_op2)		{ special_ops >> ops.repeat(1) }
	rule(:normal_op3)		{ bang >> ops.repeat }
	rule(:normal_op)		{ ( special_ops >> ops.absnt? ).absnt? >> ( normal_op1 | normal_op2 | normal_op3 ) }
	rule(:math_op)			{ match['\u2200-\u22ff'] }

			# prefix ops

	rule(:full_circum_op)		{ ( halfop >> star >> halfterm ) }

		# symbol pre-lexer rules
	rule(:symbol_prefix)	{ at | dollar }
	rule(:symbol_suffix)	{ bang | q? } 
	rule(:symbol_infix)	{ alpha | us }

	rule(:left_symbol)	{ symbol_prefix.repeat(1) >> symbol_infix.repeat >> symbol_suffix.repeat }
	rule(:right_symbol)	{ symbol_infix.repeat(1) >> symbol_suffix.repeat }
	rule(:greek_symbol)	{ match['\u0300-\u03ff'] }

	## integrate not parsing of special symbols somehow

	rule(:symbol)			{ left_symbol | right_symbol | greek_symbol }

		# regexp pre-lexer rules

	rule(:sym)			{ match['*?|.+^$\[\]{}\(\)'] }	# these are only for inside regexp
	rule(:code)			{ ( str('x') >> hex.repeat(2,2) ) | alpha | ( zero >> oct.repeat(0,3) ) | bs | fs | sym | tick | quote }

	rule(:range_expr)	{ lb >> ( decimal >> comma.maybe | decimal >> comma >> decimal | comma >> decimal ) >> rb }
	rule(:code_expr)	{ bs >> code }
	rule(:lit_expr)	{ match['^\\\/'] }
	rule(:regexp)		{ ( code_expr | range_expr | lit_expr ).repeat }

	#
	# lexer rules
	#

	rule(:comment)		{ comment_op >> match['^\n'].repeat }
	rule(:eol)			{ comment.maybe >> lf }
	rule(:terminator)		{ sc | eol | rp.prsnt? | rb.prsnt? }

	rule(:subst_regexp)	{ ( str('s') >> fs >> regexp >> fs >> ( code_expr | lit_expr ).repeat >> fs >> match['imsg'].repeat ).as(:subst_regexp) >> space? }
	rule(:match_regexp)	{ ( fs >> regexp >> fs >> match['ims'].repeat ).as(:match_regexp) >> space? }

	rule(:unicode)			{ ( str('U+') >> hex.repeat(4,4) ).as(:unicode) >> space? }

	rule(:if_ctrl)			{ str('if') >> space? }
	rule(:then_ctrl)		{ str('then') >> space? }
	rule(:else_ctrl)		{ str('else') >> space? }
	rule(:elif_ctrl)		{ str('elif') >> space? }
	rule(:is_ctrl)			{ str('is') >> space? }
	rule(:do_ctrl)			{ str('do') >> space? }
	rule(:wait_ctrl)		{ str('wait') >> space? }
	rule(:each_ctrl)		{ str('each') >> space? }
	rule(:all_ctrl)		{ str('all') >> space? }
	rule(:while_ctrl)		{ str('while') >> space? }
	rule(:rescope_ctrl)	{ str('rescope') >> space? }

	rule(:special_symbols)	{ if_ctrl | then_ctrl | else_ctrl | elif_ctrl | is_ctrl | do_ctrl | wait_ctrl | each_ctrl | all_ctrl | while_ctrl | rescope_ctrl }

	rule(:base)				{ str('...') }

	rule(:single_qu)		{ ( tick >> match['^\''].repeat >> tick ).as(:single_qu) >> space? }
	rule(:double_qu)		{ ( quote >> ( code_expr | match['^"'] ).repeat >> quote ).as(:double_qu) >> space? } 

	rule(:integer_val)	{ ( sign.maybe >> ( binary | octal | decimal | hexidecimal ) ).as(:integer_val) >> space? }
	rule(:real_val)		{ float.as(:real_val) >> space? }
	rule(:boolean_val)	{ ( boolean_true | boolean_false | boolean_null ).as(:boolean_val) >> space? }

		# operators (prefix) -- aka symbols or operator nodes -- need to make more consistent descriptions

	rule(:prefix_op)		{ ( full_circum_op ).as(:prefix_op) >> space? }

		# operators (infix)

	rule(:infix_op)		{ normal_op | math_op }

	# half operators are circumfix operators applied as such

	rule(:half_op)			{ halfop.as(:half_op) >> space? }
	rule(:half_term)		{ halfterm.as(:half_term) >> space? }

	# parser rules

	rule(:nop)				{ space? >> eol }

		# link

	rule(:link)				{ ( node.as(:from) >> space? >> right_arrow >> space? >> node.as(:to) ).as(:link) >> space? }

		# path

		# currently nodes somehow could comeout to be bare ops, which shouldnt be a case

	rule(:op_name)			{ infix_op | full_circum_op }
	rule(:name)				{ symbol | op_name }

	rule(:p_node)			{ p_expr >> dot >> part.repeat >> name >> space? }
	rule(:b_node)			{ base >> part.repeat >> name.maybe >> space? }
	rule(:s_node)			{ part.repeat(1) >> name >> space? }
	rule(:a_node)			{ symbol >> space? }

	rule(:node)				{ p_node | s_node | b_node | a_node }

	rule(:part)				{ symbol >> dot }

		# rescope

	rule(:rescope)			{ rescope_ctrl.as(:rescope) >> space? >> node.as(:node) >> space? }

		# assign

		# important fact : nodes can always accept assignment -- this is a critical distinction from expressions.
		# expressions cannot accept assignment and this distinction arises from function calls. as you can always
		# attempt to call a function, which MAY be a node buy also MAY be a p-expression or a literal expression.
		# literals are good examples of ambiguity, literals are always treated like functions, and never like nodes.
		# and because literals must be considered constant, they cannot accept assignment.
	
	rule(:assign)			{ list_assign | node_assign }

	rule(:node_assign)	{ ( node.as(:to) >> space? >> left_arrow >> space? >> expr.as(:from) ).as(:node_assign) }
	rule(:list_assign)	{ ( node.as(:head) >> list_op >> node.as(:tail) >> space? >> left_arrow >> space? >> expr.as(:from) ).as(:list_assign) }

		# each

	rule(:each)				{ str("unimplemented_replace") }

		# expr

	rule(:expr)			{ ( call_expr | cond_expr | f_expr ).as(:expr) }

	rule(:p_expr)			{ lp >> space? >> expr >> space? >> rp >> space? }
	rule(:literal_expr)	{ string_literal | regexp_literal | numeric_literal }
	rule(:call_expr)		{ infix_call | prefix_call | circum_call }

	rule(:v)					{ symbol.as(:v) >> space? }

	rule(:lambda_expr)	{ ( lb >> space? >> v.repeat.as(:vs) >> pipe >> space? >> program >> space? >> rb ).as(:lambda_expr) >> space? }

	rule(:cond_expr)		{ if_expr >> space? >> elif_expr.repeat >> space? >> else_expr.maybe >> space? }
	rule(:all_expr)		{ str("unimplemented_replace") }
	rule(:do_expr)			{ do_ctrl >> space? >> expr >> space? }
	rule(:wait_expr)		{ wait_ctrl >> space? >> expr >> space? }

			# literal_expr

	rule(:string_literal)	{ single_qu | double_qu | unicode }
	rule(:regexp_literal)	{ match_regexp | subst_regexp }
	rule(:numeric_literal)	{ integer_val | real_val | boolean_val }

			# call_expr

	rule(:f_expr)				{ literal_expr | p_expr | lambda_expr | all_expr | do_expr | wait_expr | node }

	rule(:infix_call)			{ ( f_expr.as(:f) >> space? >> infix_op.as(:infix_op) >> space? >> p.as(:ps) ).as(:infix_call) }
	rule(:prefix_call)		{ ( f_expr.as(:f) >> p.repeat.as(:ps) ).as(:prefix_call) }
	rule(:circum_call)		{ ( half_op >> f_expr.as(:f) >> p.repeat.as(:ps) >> half_term ).as(:circum_call) }

	rule(:p)						{ ( free | expr ).as(:p) >> space? }

		# command

	rule(:command)				{ space? >> ( link | assign | each | expr | rescope ).as(:command) >> terminator }

		# program

	rule(:program)				{ ( command | nop ).repeat }

	root :program
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
