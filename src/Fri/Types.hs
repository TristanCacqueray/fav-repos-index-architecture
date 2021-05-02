{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- | The data types
module Fri.Types where

import Data.Aeson (FromJSON (..), ToJSON (..), Value (String), genericParseJSON, genericToJSON, withText)
import Data.Aeson.Casing (aesonPrefix, snakeCase)
import Data.Aeson.Types (Parser)
import Data.Time.Clock (UTCTime)
import Data.Time.Format (defaultTimeLocale, formatTime, parseTimeM)
import qualified Fri.Messages as PB
import Relude

newtype IsoTime = IsoTime UTCTime deriving stock (Show, Eq)

instance ToJSON IsoTime where
  toJSON (IsoTime utcTime) = String . toText . formatTime defaultTimeLocale "%FT%TZ" $ utcTime

instance FromJSON IsoTime where
  parseJSON = withText "IsoTime" (parse . toString)
    where
      elkApiFormat = "%FT%TZ"
      tryParse f s = parseTimeM False defaultTimeLocale f s
      parse :: String -> Parser IsoTime
      parse s = IsoTime <$> tryParse elkApiFormat s

data User = User
  { userFavorites :: Int,
    userFavoritesUpdatedat :: IsoTime
  }
  deriving (Show, Eq, Generic)

instance ToJSON User where
  toJSON = genericToJSON $ aesonPrefix snakeCase

instance FromJSON User where
  parseJSON = genericParseJSON $ aesonPrefix snakeCase

type RegisterImpl m = UserName -> (Either Text PB.Repo -> m ()) -> m ()

type SearchImpl m = Text -> (PB.Repo -> m ()) -> m ()

data RepoInitial = RepoInitial
  { riName :: RepoName,
    riDescription :: Maybe RepoDescription
  }
  deriving (Show, Eq)

riDesc :: Maybe RepoDescription -> Text
riDesc = maybe "" unDesc

newtype UserName = UserName Text deriving (Show, Eq, ToJSON, FromJSON)

newtype RepoName = RepoName Text deriving (Show, Eq)

newtype RepoTags = RepoTags Text deriving (Show, Eq)

newtype RepoDescription = RepoDescription {unDesc :: Text} deriving (Show, Eq)
