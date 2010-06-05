#!/usr/bin/p

-- all native values are considered nullary functions

integer <- 5
binary <- 0x1111
hex <- 0xFFFF
oct <- 0777
float <- 3.1415e0

-- a list of values demonstrating the various numeric formats

fs <- 666:0666:0x666:666.:.666:6.6e6:.6e6:-6.e6:+6.e6:6e6:6.e6:+6e6:-6e6:-666:+666:0b11:0B00:0X00:0xff

-- assign a string to a root node (string)

...string <- "\033[1mhello \"\\bob\x1b[0m\r\n"

-- rescope to the root (which is the default anyways)

rescope ...

-- node paths are created on demand

a.path.to.a.value <- "hello world\n"

rescope a.path.to

...print a.value

-- some extra node linking

...a -> ...a.path.to.a.value

...print ...a.value

-- defined string concatenation : a ++ b

String.++ <- { s | @ + s }

-- concatenate a string onto ...string

string <- string ++ 'well, well, well...'

-- define string.clear

@.String.clear <- { | @ <- '' } 

-- alias ...clear to string clear
-- this has the effect of being a nullary function on the root node
-- ...clear or just clear when scope is ... which will blank out the root node

clear -> String.clear

-- assign a regex to ...match, which acts as unary function and should
-- be used with its native category of strings/matching monoid

match <- /\what.\b*is\s+upp[[:alnum:]]\/\\$/

match <- /(wel+,?)/

matched? <- string ~ match

-- assign a substitution regex to \.subst which acts as a unary function on
-- strings. which should be used with the strings/subs monoid

subst <- s/wel+,?/fell/

replaced! <- string ~ subst

-- start an empty list ($), initialize n to zero and then build a list of values
-- also, pairing with the empty list is the identity function ( x <- $:x ) == x

list <- $

n <- 0

while n < 10 { | list <- list : if n > 5 then n else n + n }

-- breaking a pair up is straight forward
-- allowing arbitrary pairs to build trees though make it difficult
-- to facilitate head/tail splitting operation on lists
-- this may force ':' to act as list concatenation instead of pairing

x:xs <- list

-- SKI combinator calculus

S <- { x y z | ( x z ) ( y z ) }
K <- { x y | x }
I <- { x | x }
 
-- extending a list type with a size function is easy
-- just define an autocircumfix operator

List.|*| <- { |
    sz <- 0
    all @ I { | sz <- sz + 1 }
    sz
}    

-- array-like access is the wrong way to go about things
-- but if you want to do it, its easy to define
-- a regular circumfix operator for [] will do it

List.[?] <- { n |
    xs <- @
    all N { m | m < n } { x:xs <- xs }
    x:xs <- xs
    x
}    

...print ( sprintf "the %dth item of the list is %d\n" 4 list[4] )

-- quicksort a list

quicksort <- { xs |
    if xs == $ then $           -- if xs is empty, then return an empty list
    elseif |xs| == 1 then xs    -- if xs has 1 element then return xs
    else do { |                 -- otherwise quicksort sub-lists and concatenate
        x:xs <- xs
        left <- all xs { lx | lx < x }
        right <- all xs { rx | lx >= x }
        ( quicksort left ) : x : ( quicksort right )
    }
}    

-- various ways to iterate over a range of numbers
-- quantifiers when applied to types with total orderings will stop after the first false expression evaluation
-- when possible, types will be enumerated in their natural order, enumeration is otherwise lazy

all N { n | n < 10 } { n | ...print ( sprintf "number %d\n" n ) }

-- the standard increment and loop while is also straightforward

n <- 0

while n < 10 { | n <- n + 1 }

-- although not a native part of the language, post-increment is easy to implement

Number.++ <- { |
        n <- @ 
        @ <- @ + 1 
        n
}

-- build a small list of 3 items in two different ways

v <- 3
v <- v:4
v <- v:5

w <- 3:4:5

-- define and calculate the vector norm using the autocircumfix operator |*|

Vector.|*| <- { | sqrt ( sum ( map @ { x | x * x } ) ) }   

v_norm <- |v|

w_norm <- |w|

-- each special scoping path has both a symbolic and named form

...print if root is ... then "root is ...\n" else "root is not ...\n"
...print if local is ! then "local is !\n" else "local is not !\n"
...print if self is @ then "self is @\n" else "self is not @\n"

-- define a function that adds 3 numbers together

add3 <- { x y z | x + y + z }

-- half-application currying of add3 to get an add2 function by binding an arbitrary parameter to 0

add2 <- add3 ? ? 0

-- make some parent and children nodes and add some parent aliases

...parent <- 'the parent'

rescope ...parent

child1 <- 'child 1'
child2 <- 'child 2'
child3 <- 'child 3'

-- link childN.parent to the parent node (currently self)

child1.parent -> @
child2.parent -> @
child3.parent -> @

rescope ...

all 'child1':'child2':'child3' I { s |
    rescope parent.`s
    ...print ( sprintf "%s from %s\n" @ parent )
}
