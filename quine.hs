main :: IO ()
main = putStrLn (s ++ show s)
  where
    s = "main :: IO ()\nmain = putStrLn (s ++ show s)\n  where\n    s = "
