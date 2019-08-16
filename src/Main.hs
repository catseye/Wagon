module Main where

import System.Environment
import System.Exit
import System.IO

import qualified Language.Wagon.ConcatEval as ConcatEval
import qualified Language.Wagon.SymInterp as SymInterp
import qualified Language.Wagon.Depict as Depict


main = do
    args <- getArgs
    case args of
        ["run", fileName] -> do
            text <- readFile fileName
            putStrLn $ show $ ConcatEval.run text
            return ()
        ["eval", fileName] -> do
            text <- readFile fileName
            putStrLn $ show $ SymInterp.run text
            return ()
        ["depict", fileName] -> do
            text <- readFile fileName
            putStrLn $ Depict.depict text
            return ()
        _ -> do
            abortWith "Usage: wagon (run|eval|depict) <wagon-program-text-filename>"

abortWith msg = do
    hPutStrLn stderr msg
    exitWith (ExitFailure 1)
