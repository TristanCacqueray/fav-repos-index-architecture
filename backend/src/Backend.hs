{-# LANGUAGE NoImplicitPrelude #-}

-- |
module Backend where

import GRPC.Api (run)
import Relude

run :: Int -> Text -> IO ()
run port elk = do
  putTextLn $ "FRI backend running on :" <> show port
  GRPC.Api.run port
