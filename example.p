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

## unicode support!
## single greek letters (0300-03ff) are considered symbols
## single mathematical operators (2200-22ff) are considered infix operators

π <- 3.14159265 ## PI

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

String.++ <- { s | @ <- @ + s }

## concatenate a string onto ...string

string ++ 'well, well, well...'
string ++ U+534D

## define string.clear

@.String.clear <- { | @ <- '' } 

## alias ...clear to string clear
## this has the effect of being a nullary function on the root node
## ...clear or just clear when scope is ... which will blank out the root node

@ -> String.clear

## some weird operators

...last -> @ ## FIXME: this shouldn't be link but alias, which needs a new operator

rescope Integer

` <- I ## this might be illegal because this in another context is a kind of de-ref of path strings
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

each (N) while { n | n < 10 } { n | list <- list : if n > 5 then n else n + n }

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
## just define an autocircumfix operator (. inbetween operator symbols)

List.{{.}} <- { |
    sz <- 0
    each (@) (I) { a | sz <- sz + 1 }
    sz
}    

## array-like access is the wrong way to go about things
## but if you want to do it, its easy to define
## a regular circumfix operator for [] will do it (* inbetween operator symbols)

List.[*] <- { k |
    xs <- @
    each (N) while { n | n < k } { n | x:xs <- xs }
    x:xs <- xs
    x
}    

List.<<.>> <- I

...print ( sprintf "the %dth item of the list is %d\n" 4 list[4] )

## quicksort a list

quicksort <- { xs |
    if xs == $ then $           ## if xs is empty, then return an empty list
    elif {{xs}} == 1 then xs    ## if xs has 1 element then return xs
    else do { |                 ## otherwise quicksort sub-lists and concatenate
        x:xs <- xs
        left <- all (xs) { lx | lx < x }
        right <- all (xs) { rx | lx >= x }
        (quicksort left):x:(quicksort right)
    }
}    

## fold left and fold right reduction functions

foldl <- { z f xs |
    if xs == $ then z
    else do {
        x:xs <- xs
        foldl (f z x) f xs
    }
}

foldr <- { z f xs |
    if xs == $ then z
    else do { |
        x:xs <- xs
        f x (foldr z f xs)
    }
}

## function composition with the circle operator

∘ <- { g f | { x | g (f x) } }

## since list building isnt a true lambda we have to make one

concat <- { xs x | xs:x }

## basic recursive definition of map

map <- { f xs |
    if xs == $ then $
    else do { |
        x:xs <- xs
        (f x):(map f xs)
    }
}

## basic iterative definition of map

map_each <- { f xs |
    ys <- $
    each (xs) (I) { x | ys <- ys:(f x) }
    ys
}

## the slick definition of map with the composition of concatenation and f

map_slick <- { f xs | foldl $ (concat ? (f ?)) xs }

## if not all parameters to an expression are filled out then the lambda expression itself is passed instead of the evaluation (i hope)
## the concern i have is that since the function is an adjacent node to the accumulated value, delaying its association until the call
## might pose problems for compilation or the interpreter

## are all in theory lists (except R shouldnt be a list) the enumeration method of Q should be
## cantor diagonalization omitting reducible fractions. the elements should be some form of number
## but probably there should be a Fraction class.
## these are also in theory constructors for List derivative types
## on another note, I is the identity constructor function (constructs in full the type+value passed to it)

numbers <- Z:Q:N

ℕ <- N ## lol

Σ <- { xs | foldl 0 (+) xs }

Π <- { xs | foldr 1 (*) xs }

sum <- Σ all (ℕ) while { n | n < 5 }

prod <- Π all (N) while { n | n < 5 }

## quantifiers when applied to types with total orderings will stop after the first false expression evaluation
## when possible, types will be enumerated in their natural order, enumeration is otherwise lazy

each (N) while { n | n < 10 } { n | ...print ( sprintf "number %d\n" n ) }

## although not a native part of the language, post-increment is easy to implement
## this one issue with using it is that operators are considered infix unless the explicit path is referenced and
## the parameter set is terminated correctly so it would have to be called very un-ambiguously

Number.++ <- { |
        n <- @ 
        @ <- @ + 1 
        n   ## the value of a lambda is the value of the last evaluation
}

x <- 666

## newlines and close parens terminate a parameter list

x.++

y <- (x.++) + 10

## immedate vs. delayed evaluation of lambda expressions

...value <- 50

immediate <- do { | ...value }
later <- { | ...value }

...value <- ...value + 10

...print ( sprintf "immediate=%d\n" imediate )
...print ( sprintf "later=%d\n" later )

## define and calculate the vector norm using the autocircumfix operator <<.>>

## FIXME: how does Vector inheirit from List
## if Constructor symbols are all of type Type then copying one should in theory work if
## the associated node links are copied over also

Vector <- List

Vector.<<.>> <- { | sqrt (sum (map { x | x * x } @)) }

## FIXME: how should these defer? what if you wanna copy a nullary lambda without executing it or linking it?
## should auto-circumfix operators be assigned to unary lambdas instead? should there be a postpone keyword?
## the original idea was that if the correct number of parameters to a lamda is passed at any given moment, it
## is evaulated, otherwise it is curryed, unless a literal lambda is expressed in which it is postponed.

List.<<.>> -> Vector.<<.>>
List.<<.>> <- Vector.<<.>>
List.<<.>> <- wait Vector.<<.>>

## build a small list of 3 items in two different ways as Vectors

## FIXME: how does one instantiate a class (Vector in this case)
## maybe class name symbols are constructors

v <- Vector 3
v <- v:4
v <- v:5

w <- Vector 3:4:5

## figure the norms

v_norm <- <<v>>

w_norm <- <<w>>

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

## back-tick means treat string as path FIXME: i dont think this is actually dealt with

each 'child1':'child2':'child3' (I) { s |
    rescope parent.`s
    ...print ( sprintf "%s from %s\n" @ parent )
}

## FIXME: how does one get a list of adjacent nodes?
