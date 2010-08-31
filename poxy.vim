" Vim syntax file
" Language:		P/Oxy
" Maintainer:		Christopher Abad <aempirei@gmail.com>
" Last Change:		2010 Jun 7
" Original Author:	Christopher Abad <aempirei@gmail.com>
"
" Remove any old syntax stuff hanging around
if version < 600
	syn clear
elseif exists("b:current_syntax")
	finish
endif

syn match	poxyOperators	"[-^=+\[\]<>?/\\,:;*&~|%#@!]\{1,\}"
syn match	poxyLambda		"[{|}]"
syn match	poxyBars		"\[\+\|\]\+\|{{\+\|}}\+\|<<\+\|>>\+"
syn match	poxyNode		"\<[a-z_][[:alnum:]_]*!*\>[!?]*"
syn match	poxyType		"\<[A-Z][a-zA-Z]*\>"
syn match	poxyAssign		"<-"
syn match	poxyEdge		"->"
syn match	poxyLink		"[.]"
syn match	poxyParen		"[()]"
syn match	poxyOperator	"[~:]"
syn match	poxySpecialNode "[@!$]\|\.\.\."
syn match	poxyParam		"[?*]"
syn match	poxyWrap		"\\$"

syn match	poxySpecialChar	contained	"\\\([0-9]\+\|o[0-7]\+\|x[0-9a-fA-F]\+\|[\"\\'&\\abfnrtv]\|^[A-Z^_\[\\\]]\)"
syn match	poxyRegexpChar	contained	"\\\([0-9]\+\|o[0-7]\+\|x[0-9a-fA-F]\+\|[\"\\'&\\abfnrtvbBdDsSwW]\|^[A-Z^_\[\\\]]\)"
syn match	poxySpecialChar	contained	"\\\(NUL\|SOH\|STX\|ETX\|EOT\|ENQ\|ACK\|BEL\|BS\|HT\|LF\|VT\|FF\|CR\|SO\|SI\|DLE\|DC1\|DC2\|DC3\|DC4\|NAK\|SYN\|ETB\|CAN\|EM\|SUB\|ESC\|FS\|GS\|RS\|US\|SP\|DEL\)"

syn region	poxyString	start=+"+		skip=+\\\\\|\\"+	end=+"+				contains=poxySpecialChar
syn region	poxyRegexp	start=+/+		skip=+\\\\\|\\/+	end=+/[ims]*+		contains=poxyRegexpChar

syn region	poxyLiteral start=+'+							end=+'+
syn match	poxySubst "\<s/\(\\/\|[^/]\)*/\(\\/\|[^/]\)*/[ims]*"				contains=poxyRegexpChar

syn match   poxyNumber	"\(\<\|[+-]\)\(0\|[1-9][[:digit:]]*\|0[dD][[:digit:]]\+\|0[xX][[:xdigit:]]\+\|0[bB][01]\+\|0[oO]\?[0-7]\+\)\>"
syn match	poxyBoolean	"\<\(true\|false\|null\|U+[[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]]\)\>"
syn match   poxyFloat1  "\(\<\|[+-]\)\(0\|[1-9][[:digit:]]*\)\.\([[:digit:]]\+\>\)\?"
syn match   poxyFloat2  "\(\<\|[+-]\)\(0\|[1-9][[:digit:]]*\)\.[[:digit:]]*\([eE][+-]\?\(0\|[1-9][[:digit:]]*\)\?\)\>"

syn match	poxyError "\<\(0[89][^ ]*\)"

syn match poxyConditional		"\<\(if\|then\|else\|elif\)\>"
syn match poxyKeyword			"\<\(is\|do\|each\|while\|all\|rescope\)\>"

syn match	poxySharpBang	"^#!.*"
syn match	poxyComment		"##.*"

if version >= 508 || !exists("did_poxy_syntax_inits")
  if version < 508
    let did_poxy_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink poxyError			Error

  HiLink poxySharpBang		PreProc
  HiLink poxyEdge			Operator
  HiLink poxyAssign			Operator
  HiLink poxyLink			Delimiter
  HiLink poxyType			Type
  HiLink poxyOperator		Operator
  HiLink poxyOperators		Operator
  HiLink poxyLambda			PreProc
  HiLink poxyWrap			PreProc

  HiLink poxyConditional	Conditional
  HiLink poxyKeyword		Conditional
  HiLink poxySpecialNode	String
  HiLink poxyBars			Operator
  HiLink poxyParam			Delimiter

  " comment

  HiLink poxyComment		Comment

  " escape chars & special chars for strings

  HiLink poxyRegexpChar		SpecialChar
  HiLink poxySpecialChar	SpecialChar

  " string values (nullary functions)

  HiLink poxyString			String
  HiLink poxyLiteral		String
  HiLink poxyRegexp			String
  HiLink poxySubst			String

  " values (nullary functions)

  HiLink poxyCharacter		Character
  HiLink poxyNumber			Number
  HiLink poxyFloat1			Float
  HiLink poxyFloat2			Float
  HiLink poxyFloat3			Float
  HiLink poxyFloat4 		Float
  HiLink poxyFloat5			Float
  HiLink poxyBoolean		Boolean

  delcommand HiLink
endif

let b:current_syntax = "poxy"
