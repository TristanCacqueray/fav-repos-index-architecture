{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE NoImplicitPrelude #-}

-- | The api functions
module Fri.Api (run) where

import Control.Monad.Catch (MonadThrow)
import qualified Data.Vector as V
import Fri.GitHub (getFavorites)
import qualified Fri.Messages as PB
import Fri.Query
import Fri.RpcApi (runService)
import Fri.Types
import Relude
import qualified Streaming.Prelude as S

register :: (MonadThrow m, MonadIO m) => Client -> RegisterImpl m
register client username sendResult = do
  -- Check if user already registered
  userM <- runQuery client $ getUser username
  case userM of
    Just _user -> sendResult (Left "welcome back!")
    Nothing -> do
      _ <- runQuery client $ createUser username
      initRepos <- S.toList_ userFavRepo
      runQuery client (addRepos (V.fromList initRepos))
      mapM_ (sendResult . Right . toRepo) initRepos
      sendResult (Left "welcome!")
  where
    userFavRepo = getFavorites username
    toRepo :: RepoInitial -> PB.Repo
    toRepo (RepoInitial (RepoName name) desc) =
      PB.Repo
        (toLazy name)
        []
        (toLazy . unDesc $ fromMaybe (RepoDescription "") desc)
        []

search :: (MonadThrow m, MonadIO m) => Client -> SearchImpl m
search client txt sendResult = do
  res <- runQuery client $ searchRepos txt
  mapM_ sendResult res

run :: Int -> Text -> IO ()
run port elk = do
  elkClient <- newClient elk
  putTextLn $ "fri-api running on :" <> show port
  runService port (register elkClient) (search elkClient)
