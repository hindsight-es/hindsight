module Main where

import Control.Concurrent (threadDelay)
import System.Process (readProcess)
import Test.KurrentDB.Tmp

main :: IO ()
main = do
    putStrLn "=== Testing tmp-kurrentdb ==="

    withTmpKurrentDB $ \config -> do
        putStrLn $ "Container started on port: " ++ show (port config)

        -- Try to connect to the port
        result <- readProcess "nc" ["-zv", "localhost", show (port config)] ""
        putStrLn $ "Port check result: " ++ result

        putStrLn "✓ tmp-kurrentdb working!"
