{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeOperators #-}

-- |
module Main (main) where

import Backend
import Options.Generic

data CLI w = CLI
  { elkUrl :: w ::: Int <?> "The ELK service url"
  }
  deriving stock (Generic)

main :: IO ()
main = do
  args <- unwrapRecord "Lentille worker"
  Backend.run (elkUrl args)
