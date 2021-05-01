{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE NoImplicitPrelude #-}

-- | The api functions
module Fri.Api (run) where

import Fri.Types
import Protos (runService)
import Protos.Fri (Repo (..))
import Relude

register :: MonadIO m => RegisterImpl m
register username sendResult = do
  mapM_ sendResult (map Right fakeRepos)
  sendResult (Left "welcome!")
  where
    fakeRepos =
      [ Repo "testy" ["haskell"] "a test project" [],
        Repo "testo" ["rescript", "html"] "a test client" []
      ]

run :: Int -> Text -> IO ()
run port elk = do
  putTextLn $ "fri-api running on :" <> show port
  runService port register
