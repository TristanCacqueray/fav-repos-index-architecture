-- | The data types
module Types (Repo (..), RegisterImpl) where

import Protos.Fri (Repo (..))
import Relude

type RegisterImpl m = Text -> (Either Text Repo -> m ()) -> m ()
