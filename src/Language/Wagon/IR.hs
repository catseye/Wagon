module Language.Wagon.IR where

--
-- Intermediate representation for Wagon programs;
-- used in the symbolic interpreter and the depictor;
-- could be used in a compiler as well.
--

data Op = Push1
        | Sub
        | Pop
        | Dup
        | Rev
        | If Op
        | While Op
        | Cons Op Op
        | Nil
   deriving (Show, Ord, Eq)

appA op = m where m x = Cons op x  -- After
appB op = m where m x = Cons x op  -- Before

ic 'i'  = appA Push1
ic 'I'  = appB Push1

ic 's'  = appA Sub
ic 'S'  = appB Sub

ic 'p'  = appA Pop
ic 'P'  = appB Pop

ic 'd'  = appA Dup
ic 'D'  = appB Dup

ic 'r'  = appA Rev
ic 'R'  = appB Rev

ic '@'  = mwhile where mwhile op = While op

ic ' '  = id
ic '\t' = id
ic '\n' = id
ic '\r' = id

parse [] = id
parse (c:cs) = (parse cs) . (ic c)

compile t = (parse t) Nil
