{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

-- | A module to manage elasticseach query with bloodhound
-- https://github.com/bitemyapp/bloodhound
module Fri.Query where

import Control.Monad.Catch (MonadThrow)
import Data.Aeson (ToJSON (..), object, (.=))
import Data.Aeson.Types (Pair)
import qualified Data.Vector as V
import qualified Database.Bloodhound as BH
import Fri.Types
import Network.HTTP.Client (defaultManagerSettings, newManager)
import Relude

friIndex :: BH.IndexName
friIndex = BH.IndexName "fri.0"

data RepoMapping = RepoMapping deriving stock (Eq, Show)

-- | The Repo document mapping
-- >>> putTextLn . decodeUtf8 . encode $ RepoMapping
-- {"properties":{"topics":{"type":"keywords"},"text":{"type":"description"},"stargazers":{"type":"keywords"},"integer":{"type":"starts"}}}
instance ToJSON RepoMapping where
  toJSON RepoMapping = object ["properties" .= object props]
    where
      props =
        keywords ["topics", "stargazers"]
          <> [ setPropType "description" "text",
               setPropType "starts" "integer"
             ]
      keywords :: [Text] -> [Pair]
      keywords = map (setPropType "keywords")
      setPropType :: Text -> Text -> Pair
      setPropType propType prop = prop .= object ["type" .= propType]

-- | Add new repos
-- >>> :{
-- newClient "http://localhost:9242" >>=
--     \client -> runQuery client $ addRepos [RepoName "test-owner/repo"]
-- }:
addRepos :: (MonadThrow m, MonadIO m) => V.Vector RepoInitial -> Query m ()
addRepos repos = do
  checkResp "add repos" <$> BH.bulk (fmap mkOps repos)
  elkLog $ "Indexed " <> show (V.length repos) <> " repo(s)"
  where
    mkOps (RepoInitial (RepoName name) desc) =
      BH.BulkIndex
        friIndex
        (BH.DocId name)
        ( object ["description" .= riDesc desc]
        )

initialize :: (MonadThrow m, MonadIO m) => Query m ()
initialize = do
  putTextLn "Initalizing indexes"
  checkResp "index creation" <$> BH.createIndex indexSettings friIndex
  checkResp "mapping" <$> BH.putMapping friIndex RepoMapping
  indices <- BH.listIndices
  elkLog $ "Indexes: " <> show indices
  where
    indexSettings = BH.IndexSettings (BH.ShardCount 1) (BH.ReplicaCount 0)

-------------------------------------------------------------------------------
-- Low level helper functions
-------------------------------------------------------------------------------
type Client = BH.BHEnv

type Query m a = BH.BH m a

checkResp :: Text -> BH.Reply -> ()
checkResp name resp
  | BH.isSuccess resp = ()
  | otherwise = error (name <> ": " <> show resp)

runQuery :: Client -> Query m a -> m a
runQuery = BH.runBH

newClient :: (MonadThrow m, MonadIO m) => Text -> m Client
newClient server = do
  manager <- liftIO $ newManager defaultManagerSettings
  let client = BH.mkBHEnv (BH.Server server) manager
  runQuery client initialize
  pure client

elkLog :: MonadIO m => Text -> m ()
elkLog msg = putTextLn $ "[elk] " <> msg
