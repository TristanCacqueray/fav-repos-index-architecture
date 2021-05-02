-- | The data types
module Fri.Types where

import qualified Fri.Messages as PB
import Relude

type RegisterImpl m = UserName -> (Either Text PB.Repo -> m ()) -> m ()

data RepoInitial = RepoInitial
  { riName :: RepoName,
    riDescription :: Maybe RepoDescription
  }
  deriving (Show, Eq)

riDesc :: Maybe RepoDescription -> Text
riDesc = maybe "" unDesc

newtype UserName = UserName Text deriving (Show, Eq)

newtype RepoName = RepoName Text deriving (Show, Eq)

newtype RepoTags = RepoTags Text deriving (Show, Eq)

newtype RepoDescription = RepoDescription {unDesc :: Text} deriving (Show, Eq)
