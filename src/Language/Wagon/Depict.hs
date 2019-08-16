module Language.Wagon.Depict where

--
-- Convert an intermediate representation to a string which
-- reads like a program in a conventional nested programming language.
--

import Language.Wagon.IR


nestDepict (While op) = "(while " ++ (nestDepict op) ++ ")"
nestDepict (Cons Nil b) = nestDepict b
nestDepict (Cons a Nil) = nestDepict a
nestDepict (Cons a b) = (nestDepict b) ++ " " ++ (nestDepict a)
nestDepict Nil = ""
nestDepict other = (show other)

depict t = nestDepict (compile t)
