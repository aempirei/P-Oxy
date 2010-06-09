##
## The P Programming Language
##
## pointless example code 
##
## Copyright(c) 2010 by Christopher Abad
## 20 GOTO 10 | aempirei@gmail.com
##

print "hello world"

    \
    \
    \

## all native values are considered nullary functions

integer <- 5
binary <- 0b1111
hex <- 0xFFFF
oct <- 0777
float <- 3.1415e0

math <- (4 + 77) - 2 * 3 + 1 + -1 + (1 + (2 + 3))
string <- "hello" + 'bob'
match <- "shit" ~ /hi/

wrap_line <- 1 + \
             2 + \
             3

## a list of values demonstrating the various numeric formats

dec <- 666 : 0d666 : -0d666 : +0d666 : 0d0 : 0
hex <- 0x666 : 0XFFF : 0x0 : -0X0 : +0X0
oct <- 00 : 01 : 0777 : -01 : +01 : 0o0 : 0O7
bin <- 0b0 : 0b1 : -0B1 : +0B1
float <- 0. : 0.0 : 10.0 : 10. : -666. : +666. : +666.666
float <- 0.e0 : 0.0e-1 : 10.0e+2 : 10.e+0 : -666.e11 : +666.e+10 : +666.666e-0

## assign a string to a root node (string)

...string <- '\033[1 this is a literal

nothing is escaped \"\r\n'

...string <- "\033[1mhello \"\\bob\x1b[0m\r\n"

## rescope to the root (which is the default anyways)

rescope ...

## node paths are created on demand

a.path.to.a.value <- "hello world\n"

rescope a.path.to

...print a.value

## some extra node linking

...a -> ...a.path.to.a.value

...print ...a.value

## define string concatenation : a ++ b

String.++ <- { s | @ + s }

## concatenate a string onto ...string

string <- string ++ 'well, well, well...'

## define string.clear

@.String.clear <- { | @ <- '' } 

## alias ...clear to string clear
## this has the effect of being a nullary function on the root node
## ...clear or just clear when scope is ... which will blank out the root node

@ -> String.clear

## some weird operators

...last -> @ ## FIXME: this shouldn't be link but alias, which needs a new operator

rescope Integer

` <- I
, <- I
~ <- I

rescope ...last

## assign a regex to ...match, which acts as unary function and should
## be used with its native category of strings/matching monoid

match <- /\what.\b*is\s+upp[[:alnum:]]\/\\$/imsi

match <- /(wel+,?)/

matched? <- string ~ match

## assign a substitution regex to \.subst which acts as a unary function on
## strings. which should be used with the strings/subs monoid

subst <- s/wel+,?\n\r\x33"\"\/\\/fell\n/imsi

replaced! <- string ~ subst

## start an empty list ($), initialize n to zero and then build a list of values
## also, pairing with the empty list is the identity function ( x <- $:x ) == x

list <- $

each N { n | n < 10 } { n | list <- list : if n > 5 then n else n + n }

## breaking a list up is straight forward. this expression is a good example of
## the fact that <- works differently than a standard operator in that the l-value
## is clearly not a normal list expression in that xs cannot be replaced by an
## aribrary expression nor is 'x:xs' a node and thus <- is not an adjacency
## the bnf here is not <expr>:<expr> <- <expr> but <symbol>:<symbol> <- <expr>

x:xs <- list

## SKI combinator calculus

S <- { x y z | ( x z ) ( y z ) }
K <- { x y | x }
I <- { x | x }
 
## extending a list type with a size function is easy
## just define an autocircumfix operator (two ?'s inbetween operator symbols)

List.|??| <- { |
    sz <- 0
    each @ I { a | sz <- sz + 1 }
    sz
}    

## array-like access is the wrong way to go about things
## but if you want to do it, its easy to define
## a regular circumfix operator for [] will do it

List.[?] <- { k |
    xs <- @
    each N { n | n < k } { n | x:xs <- xs }
    x:xs <- xs
    x
}    

...print ( sprintf "the %dth item of the list is %d\n" 4 list[4] )

## quicksort a list

quicksort <- { xs |
    if xs == $ then $           ## if xs is empty, then return an empty list
    elseif |xs| == 1 then xs    ## if xs has 1 element then return xs
    else do { |                 ## otherwise quicksort sub-lists and concatenate
        x:xs <- xs
        left <- all xs { lx | lx < x }
        right <- all xs { rx | lx >= x }
        ( quicksort left ) : x : ( quicksort right )
    }
}    

## quantifiers when applied to types with total orderings will stop after the first false expression evaluation
## when possible, types will be enumerated in their natural order, enumeration is otherwise lazy

each N { n | n < 10 } { n | ...print ( sprintf "number %d\n" n ) }

## although not a native part of the language, post-increment is easy to implement

Number.++ <- { |
        n <- @ 
        @ <- @ + 1 
        n   ## the value of a lambda is the value of the last evaluation
}

## immedate vs. delayed evaluation of lambda expressions

...value <- 50

immediate <- do { | ...value }
later <- { | ...value }

...value <- ...value + 10

...print ( sprintf "immediate=%d\n" imediate )
...print ( sprintf "later=%d\n" later )

## build a small list of 3 items in two different ways

v <- 3
v <- v:4
v <- v:5

w <- 3:4:5

## define and calculate the vector norm using the autocircumfix operator |*|

Vector.|*| <- { | sqrt ( sum ( map @ { x | x * x } ) ) }   

v_norm <- |v|

w_norm <- |w|

## each special scoping path has both a symbolic and named form

...print if root is ... then "root is ...\n" else "root is not ...\n"
...print if local is ! then "local is !\n" else "local is not !\n"
...print if self is @ then "self is @\n" else "self is not @\n"

## define a function that adds 3 numbers together

add3 <- { x y z | x + y + z }

## half-application currying of add3 to get an add2 function by binding an arbitrary parameter to 0

add2 <- add3 ? ? 0

## make some parent and children nodes and add some parent aliases

...parent <- 'the parent'

rescope ...parent

child1 <- 'child 1'
child2 <- 'child 2'
child3 <- 'child 3'

## link childN.parent to the parent node (currently self)

child1.parent -> @
child2.parent -> @
child3.parent -> @

rescope ...

## back-tick means treat string as path

each 'child1':'child2':'child3' I { s |
    rescope parent.`s
    ...print ( sprintf "%s from %s\n" @ parent )
}
