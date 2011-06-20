#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'parslet'
require 'unicode'

class Mini < Parslet::Parser

	# whitespace rules

	rule(:space)		{ ( match('[ \t]') | bs >> lf ).repeat(1) }
	rule(:_)				{ space.maybe }

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

	rule(:half_op)		{ ls.repeat(1) | lb.repeat(2) }
	rule(:half_term)	{ rs.repeat(1) | rb.repeat(2) }

	rule(:special_ops)	{ comment_op | left_arrow | right_arrow | free }

		# special operators

	rule(:comment_op)		{ str('##') }
	rule(:left_arrow)		{ lt >> dash }
	rule(:right_arrow)	{ dash >> gt }
	rule(:free)				{ q? }

			# infix ops

	rule(:normal_op1)		{ required_ops >> ops.repeat }
	rule(:normal_op2)		{ special_ops >> ops.repeat(1) }
	rule(:normal_op3)		{ bang >> ops.repeat }
	rule(:legal_op)		{ ( special_ops >> ops.absnt? ).absnt? }
	rule(:normal_op)		{ legal_op >> ( normal_op1 | normal_op2 | normal_op3 ) }
	rule(:math_op)			{ match['\u2200-\u22ff'] }

			# prefix ops

	rule(:full_circum_op)		{ half_op >> half_term }

		# symbol pre-lexer rules
	rule(:symbol_prefix)	{ at | dollar }
	rule(:symbol_suffix)	{ bang | q? } 
	rule(:symbol_infix)	{ alnum | us }
	rule(:symbol_start)	{ alpha | us }

	rule(:left_symbol)	{ symbol_prefix.repeat(1) >> symbol_infix.repeat >> symbol_suffix.repeat }
	rule(:right_symbol)	{ symbol_start >> symbol_infix.repeat >> symbol_suffix.repeat }
	rule(:greek_symbol)	{ match['\u0300-\u03ff'] }

	## integrate not parsing of special symbols somehow

	rule(:legal_symbol)	{ ( special_symbols >> ( symbol_infix | symbol_suffix ).absnt? ).absnt? }

	rule(:symbol)			{ legal_symbol >> (left_symbol | right_symbol | greek_symbol ) }

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

	rule(:subst_regexp)	{ ( str('s') >> fs >> regexp >> fs >> ( code_expr | lit_expr ).repeat >> fs >> match['imsg'].repeat ).as(:subst_regexp) }
	rule(:match_regexp)	{ ( fs >> regexp >> fs >> match['ims'].repeat ).as(:match_regexp) }

	rule(:unicode)			{ ( str('U+') >> hex.repeat(4,4) ).as(:unicode) }

	rule(:if_ctrl)			{ str('if') }
	rule(:then_ctrl)		{ str('then') }
	rule(:else_ctrl)		{ str('else') }
	rule(:elif_ctrl)		{ str('elif') }
	rule(:is_ctrl)			{ str('is') }
	rule(:do_ctrl)			{ str('do') }
	rule(:wait_ctrl)		{ str('wait') }
	rule(:each_ctrl)		{ str('each') }
	rule(:all_ctrl)		{ str('all') }
	rule(:rescope_ctrl)	{ str('rescope') }

	rule(:special_symbols)	{ if_ctrl | then_ctrl | else_ctrl | elif_ctrl | is_ctrl | do_ctrl | wait_ctrl | each_ctrl | all_ctrl | rescope_ctrl }

	rule(:base)				{ str('...') }

	rule(:single_qu)		{ ( tick >> match['^\''].repeat >> tick ).as(:single_qu) }
	rule(:double_qu)		{ ( quote >> ( code_expr | match['^"'] ).repeat >> quote ).as(:double_qu) }

	rule(:integer_val)	{ ( sign.maybe >> ( binary | octal | decimal | hexidecimal ) ).as(:integer_val) }
	rule(:real_val)		{ float.as(:real_val) }
	rule(:boolean_val)	{ ( boolean_true | boolean_false | boolean_null ).as(:boolean_val) }

		# operators (infix)

	rule(:infix_op)		{ normal_op | math_op }

	# parser rules

	rule(:nop)				{ _ >> eol }

		# link

	rule(:link)				{ ( node.as(:from) >> _ >> right_arrow >> _ >> node.as(:to) ).as(:link) }

		# is -- compare references

	rule(:is_expr)			{ ( node.as(:from) >> _ >> is_ctrl >> _ >> node.as(:to) ).as(:is) }

		# path

		# currently nodes somehow could comeout to be bare ops, which shouldnt be a case

	rule(:op_name)			{ infix_op | full_circum_op }
	rule(:name)				{ symbol | op_name }

	rule(:p_node)			{ p_expr >> dot >> part.repeat >> name }
	rule(:b_node)			{ base >> part.repeat >> name.maybe }
	rule(:s_node)			{ part.repeat(1) >> name }
	rule(:a_node)			{ symbol }

	rule(:node)				{ p_node | s_node | b_node | a_node }

	rule(:part)				{ symbol >> dot }

		# rescope

	rule(:rescope)			{ rescope_ctrl.as(:rescope) >> _ >> node.as(:node) }

		# assign

		# important fact : nodes can always accept assignment -- this is a critical distinction from expressions.
		# expressions cannot accept assignment and this distinction arises from function calls. as you can always
		# attempt to call a function, which MAY be a node buy also MAY be a p-expression or a literal expression.
		# literals are good examples of ambiguity, literals are always treated like functions, and never like nodes.
		# and because literals must be considered constant, they cannot accept assignment.
	
	rule(:assign)			{ list_assign | node_assign }

	rule(:node_assign)	{ ( node.as(:to) >> _ >> left_arrow >> _ >> expr.as(:from) ).as(:node_assign) }
	rule(:list_assign)	{ ( node.as(:head) >> _ >> colon >> _ >> node.as(:tail) >> _ >> left_arrow >> _ >> expr.as(:from) ).as(:list_assign) }

		# each

	rule(:each)				{ str("unimplemented_replace") }

		# expr

	rule(:expr)				{ ( cond_expr | is_expr | call_expr | block_expr ).as(:expr) }

	rule(:p_expr)			{ lp >> _ >> expr >> _ >> rp }
	rule(:literal_expr)	{ string_literal | regexp_literal | numeric_literal }
	rule(:call_expr)		{ infix_call | prefix_call }

	rule(:big_space)		{ _ >> terminator.repeat >> _ }

	rule(:then_expr)		{ then_ctrl >> _ >> block_expr.as(:then) >> big_space }

	rule(:if_expr)			{ if_ctrl >> _ >> block_expr.as(:if) >> big_space >> then_expr.as(:then) }
	rule(:elif_expr)		{ elif_ctrl >> _ >> block_expr.as(:elif) >> big_space >> then_expr.as(:then) }
	rule(:else_expr)		{ else_ctrl >> _ >> block_expr.as(:else) }

	rule(:cond_expr)		{ if_expr >> _ >> elif_expr.repeat >> _ >> else_expr.maybe }

	rule(:a)					{ symbol.as(:a) >> _ }

	rule(:lambda_expr)	{ ( lb >> _ >> a.repeat.as(:as) >> ( colon >> _ >> a.as(:vas) ).maybe >> pipe >> _ >> program >> _ >> rb ).as(:lambda_expr) }

	rule(:all_expr)		{ all_ctrl >> _ >> block_expr.as(:all) >> _ >> block_expr.as(:where) }
	rule(:each)				{ each_ctrl >> _ >> block_expr.as(:each) >> _ >> block_expr.as(:do) }
	rule(:do_expr)			{ do_ctrl >> _ >> expr }
	rule(:wait_expr)		{ wait_ctrl >> _ >> expr }

	# circum calls get promoted to full expressions -- this might be weird
	# but this NEEDS to exist because cirum_expr MUST be f_exprs if needed

	rule(:circum_expr)		{ circum_call }

			# literal_expr

	rule(:string_literal)	{ single_qu | double_qu | unicode }
	rule(:regexp_literal)	{ match_regexp | subst_regexp }
	rule(:numeric_literal)	{ integer_val | real_val | boolean_val }

			# call_expr

	rule(:block_expr)			{ literal_expr | p_expr | circum_expr | lambda_expr | all_expr | do_expr | wait_expr }

	rule(:f_expr)				{ block_expr | node }

	rule(:infix_call)			{ ( f_expr.as(:f) >> _ >> infix_op.as(:infix_op) >> _ >> infix_p.as(:ps) ).as(:infix_call) }
	rule(:prefix_call)		{ ( f_expr.as(:f) >> _ >> prefix_p.repeat.as(:ps) ).as(:prefix_call) }
	rule(:circum_call)		{ ( half_op >> _ >> f_expr.as(:f) >> _ >> prefix_p.repeat.as(:ps) >> _ >> half_term ).as(:circum_call) }

	rule(:prefix_p)			{ ( free | block_expr | node ).as(:p) >> _ }
	rule(:infix_p)				{ ( free | expr | node ).as(:p) >> _ }

		# command

	rule(:command)				{ _ >> ( link | assign | each | expr | rescope ).as(:command) >> _ >> terminator }

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
