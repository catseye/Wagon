module Language.Wagon.SymInterp where

--
-- Symbolic version of the evaluator: the Wagon program is
-- compiled to its intermediate representation, which is interpreted.
--

import Language.Wagon.IR


eval Push1 s = (1:s)
eval Sub (a:b:s) = (b-a:s)
eval Pop s = tail s
eval Dup (x:s) = (x:x:s)
eval Rev (0:s) = reverse s
eval Rev (1:x:s) = (x:reverse s)
eval (While op) s = cwhile op s where
    cwhile op s@[] = s
    cwhile op s@(0:rest) = s
    cwhile op s@(_:rest) = cwhile op (eval op s)
eval Nil s = s
eval (Cons a b) s = eval a (eval b s)

run t = eval (compile t) []
