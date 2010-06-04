#!/usr/bin/p

-- assign a number to a root node (i)
-- all native values are considered nullary functions

fs <- 666:0666:0x666:666.:.666:6.6e6:.6e6:-6.e6:+6.e6:6e6:6.e6:+6e6:-6e6:-666:+666:0b11:0B00:0X00:0xff

-- assign a string to a root node (string)
^.string <- "\033[1mhello \"\\bob\x1b[0m\r\n"

-- rescope to the root (which is the default anyways)

rescope ^

-- defined string concatenation : a ++ b

String.++ <- { s | @ + s }

-- concatenate a string onto ^.string

string <- string ++ 'well, well, well...'

-- define string.clear

@.String.clear <- { | @ <- '' } 

-- alias ^.clear to string clear
-- this has the effect of being a nullary function on the root node
-- ^.clear or just clear when scope is ^, which will blank out the root node

clear -> String.clear

-- assign a regex to ^.match, which acts as unary function and should
-- be used with its native category of strings/matching monoid

match <- /\what.\b*is\s+upp[[:alnum:]]\/\\$/

match <- /(wel+,?)/

if string ~ match then true else false

-- assign a substitution regex to ^.subst which acts as a unary function on
-- strings. which should be used with the strings/subs monoid

subst <- s/wel+,?/fell/

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

-- quicksort a list

quicksort <- { xs |
    if xs == $ then $
    elseif |xs| == 1 then xs
    else { |
        x:xs <- xs
        left <- all xs { lx | lx < x }
        right <- all xs { rx | lx >= x }
        ( quicksort left ) : x : ( quicksort right )
    }
}    

-- various ways to iterate over a range of numbers
-- quantifiers when applied to types with total orderings will stop after the first false expression evaluation
-- when possible, types will be enumerated in their natural order, enumeration is otherwise lazy

all N { n | n < 10 } { n | ^.print ( sprintf "number %d\n" n ) }

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

-- parameter typing is pretty straight forward in theory
-- define and calculate the vector norm using the |*| operator

Vector.|*| <- { | sqrt ( sum ( map @ { x | x * x } ) ) }   

v_norm <- |v|

w_norm <- |w|

add3 <- { x y z | x + y + z }

add2 <- add3 ? ? 0

-- make some parent and children nodes and add some parent aliases

^.parent <- 'the parent'

rescope ^.parent

child1 <- 'child 1'
child2 <- 'child 2'
child3 <- 'child 3'

child1.parent -> @
child2.parent -> @
child3.parent -> @

^.print ( sprintf "%s from %s\n" child1 @ )
