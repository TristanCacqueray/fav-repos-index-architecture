{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE NoImplicitPrelude #-}

-- | A module to manage github interface
module FriGitHub where

import qualified GitHub
import Relude
import Types (Repo (..))

type UserName = Text

-- TODO: use Streaming, add ratelimit throttle...
getFavorites :: MonadIO m => Text -> m [Repo]
getFavorites username = do
  reposE <- liftIO $ GitHub.executeRequest auth request
  case reposE of
    Left err -> error $ show err
    Right repos -> mapM toRepo (toList repos)
  where
    toRepo :: MonadIO m => GitHub.Repo -> m Repo
    toRepo GitHub.Repo {..} = do
      let ownerName = GitHub.simpleOwnerLogin repoOwner
          name = GitHub.untagName ownerName <> "/" <> GitHub.untagName repoName
      putTextLn $ "Getting tags for: " <> name
      tagsE <- liftIO . GitHub.executeRequest auth $ tagRequest ownerName repoName
      case tagsE of
        Left err -> error $ show err
        Right tags ->
          pure $
            Repo
              (toLazy name)
              (fmap (toLazy . GitHub.tagName) tags)
              (toLazy $ fromMaybe "" repoDescription)
    request = GitHub.reposStarredByR (GitHub.mkOwnerName username) 1
    tagRequest owner repo = GitHub.tagsForR owner repo 1
    -- TODO: toggle caching proxy
    auth = GitHub.EnterpriseOAuth "http://localhost:8043" ""
