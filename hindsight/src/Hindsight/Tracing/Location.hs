{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

module Hindsight.Tracing.Location where

import Data.Text (Text)
import Language.Haskell.TH.Syntax (Lift (..))

data SourceLocation = SourceLocation
  { sourceFile :: Text,
    sourceModule :: Text,
    sourceLine :: Int,
    sourceColumn :: Int
  }
  deriving (Lift)

-- Convert TH Loc to our SourceLocation type

