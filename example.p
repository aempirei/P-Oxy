#!/usr/bin/p

^.i <- 666

^.string <- "\033[1mhello \"\\bob\x1b[0m\r\n"

rescope ^

string.++ <- { s | @ + s }

string <- string ++ 'well, well, well...'

@.string.clear <- { | @ <- '' } 

clear -> string.clear

string.regex <- /what.*is\s+up\/\\$/

list <- $

n <- 0

while n < 10 { | list <- list : if n > 5 then n else n + n }

x:xs <- list

n <- 0

while n < 10 { | n <- n + 1 }

-- enumerators for countable sets should be possible and just fine

all N { n | n < 10 } { n | ^.print n } 

number.++ <- { | @ + 1 }

-- parameter typing should be fine

|?| <- { Vector v | sqrt ( sum ( map v { x | x * x } ) ) }

v <- $
v <- v:3
v <- v:4

norm <- |v|

add3 <- { x y z | x + y + z }

add2 <- add3 ? ? 0




