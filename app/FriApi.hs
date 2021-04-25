{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeOperators #-}

-- |
module Main (main) where

import qualified Api
import Options.Generic

data CLI w = CLI
  { elkUrl :: w ::: Text <?> "The ELK service url",
    port :: w ::: Int <?> "The listening port"
  }
  deriving stock (Generic)

instance ParseRecord (CLI Wrapped) where
  parseRecord = parseRecordWithModifiers lispCaseModifiers

main :: IO ()
main = do
  args <- unwrapRecord "Lentille worker"
  Api.run (port args) (elkUrl args)
