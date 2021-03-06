{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE NoImplicitPrelude #-}

-- | A module to manage github interface
module Fri.GitHub where

import qualified Data.Text as T
import qualified Data.Vector as V
import Fri.Types
import qualified GitHub
import Relude
import Streaming (Of, Stream)
import qualified Streaming.Prelude as S

-- TODO: use Streaming, add ratelimit throttle...
getFavorites :: MonadIO m => UserName -> Stream (Of RepoInitial) m ()
getFavorites (UserName username) = do
  repos <- runRequest' "get repo" (request 0)
  S.each $ fmap toInitialRepo repos
  where
    toInitialRepo :: GitHub.Repo -> RepoInitial
    toInitialRepo ghr =
      let ownerName = GitHub.simpleOwnerLogin (GitHub.repoOwner ghr)
          name = GitHub.untagName ownerName <> "/" <> GitHub.untagName (GitHub.repoName ghr)
          desc = GitHub.repoDescription ghr
       in RepoInitial (RepoName name) (RepoDescription <$> desc)
    request :: Int -> GitHub.Request m (V.Vector GitHub.Repo)
    request page =
      GitHub.query
        ["users", username, "starred"]
        (fmap Just <$> [("sort", "created"), ("direction", "asc"), ("per_page", "100"), ("page", show page)])

getTags :: MonadIO m => RepoName -> m (V.Vector RepoTags)
getTags (RepoName fullRepoName) = do
  tags <- runRequest' "get tags" request
  pure $ fmap toRepoTags tags
  where
    toRepoTags = RepoTags . GitHub.tagName
    (ownerName, repoName) = T.breakOn "/" fullRepoName
    owner = GitHub.mkOwnerName ownerName
    repo = GitHub.mkRepoName repoName
    request = GitHub.tagsForR owner repo 1

-------------------------------------------------------------------------------
-- Low level helper functions
-------------------------------------------------------------------------------
runRequest' :: (MonadIO f, GitHub.ParseResponse mt b) => Text -> GitHub.GenRequest mt rw b -> f b
runRequest' name req = checkResp name <$> runRequest req

runRequest :: (MonadIO m, GitHub.ParseResponse mt a) => GitHub.GenRequest mt rw a -> m (Either GitHub.Error a)
runRequest req = liftIO $ GitHub.executeRequest auth req
  where
    -- TODO: toggle caching proxy
    auth = GitHub.EnterpriseOAuth "http://localhost:8043" ""

checkResp :: Show error => Text -> Either error result -> result
checkResp name = \case
  Left err -> error (name <> ": " <> show err)
  Right res -> res
