module Language.Wagon.ConcatEval where

--
-- Concatenative version of the evaluator: a Haskell function
-- is constructed directly from the Wagon program.
--

appA op = m where m x = (op . x)  -- After
appB op = m where m x = (x . op)  -- Before

push1 s = (1:s)
sub (a:b:s) = (b-a:s)
pop s = tail s
dup (x:s) = (x:x:s)
rev (0:s) = reverse s
rev (1:x:s) = (x:reverse s)

mwhile op = op' where
    op' s = cwhile op s
    cwhile op s@[] = s
    cwhile op s@(0:rest) = s
    cwhile op s@(_:rest) = cwhile op (op s)

ic 'i'  = appA push1
ic 'I'  = appB push1

ic 's'  = appA sub
ic 'S'  = appB sub

ic 'p'  = appA pop
ic 'P'  = appB pop

ic 'd'  = appA dup
ic 'D'  = appB dup

ic 'r'  = appA rev
ic 'R'  = appB rev

ic '@'  = mwhile

ic ' '  = id
ic '\t' = id
ic '\n' = id
ic '\r' = id

parse [] = id
parse (c:cs) = (parse cs) . (ic c)

eval t s = (t id) s

run t = eval (parse t) []
