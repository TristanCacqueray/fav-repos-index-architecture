-- | The data types
module Types where

import qualified Protos.Fri as PB
import Relude

type RegisterImpl m = Text -> (Either Text PB.Repo -> m ()) -> m ()

data RepoInitial = RepoInitial
  { riName :: RepoName,
    riDescription :: Maybe RepoDescription
  }
  deriving (Show, Eq)

newtype UserName = UserName Text deriving (Show, Eq)

newtype RepoName = RepoName Text deriving (Show, Eq)

newtype RepoTags = RepoTags Text deriving (Show, Eq)

newtype RepoDescription = RepoDescription Text deriving (Show, Eq)
