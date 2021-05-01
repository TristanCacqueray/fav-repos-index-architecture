-- | The data types
module Types (Repo (..), UserName (..), RepoName (..), RegisterImpl) where

import Protos.Fri (Repo (..))
import Relude

type RegisterImpl m = Text -> (Either Text Repo -> m ()) -> m ()

newtype UserName = UserName Text deriving (Show, Eq)

newtype RepoName = RepoName Text deriving (Show, Eq)
