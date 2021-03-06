module Helpers
    ( expandPath
    , notify
    , sleep
    , capitalize
    , toDiffTime
    , normalizeDuration
    , NotificationType(..)
    )
where

import Control.Concurrent (threadDelay)
import Data.Int (Int32)
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Data.Time.Clock (secondsToNominalDiffTime, NominalDiffTime)
import Data.Word (Word32)
import DBus (methodCall, methodCallDestination, methodCallBody, toVariant, Variant)
import DBus.Client (callNoReply, Client)
import Numeric.Natural (Natural)
import qualified Data.Text as T
import qualified Data.Char as C
import qualified Data.Map as M

import Config.Env (expandPath)

data NotificationType
    = Weather
    | Mpd
    | Twitch
    | Github Word32
    deriving (Show, Eq)

-- | Convert a natural number (in seconds) to a nominal diff time.
toDiffTime :: Natural -> NominalDiffTime
toDiffTime = secondsToNominalDiffTime . fromInteger . toInteger

-- | Convert a natural number and a fallback (both in seconds) to a nominal diff time.
-- If the provided value is lower than the fallback, the fallback is used.
normalizeDuration :: Natural -> Natural -> NominalDiffTime
normalizeDuration duration fallback =
    let
        nDuration  = toInteger duration
        nFallback  = toInteger fallback
        normalized = if nDuration < nFallback then nFallback else nDuration
    in secondsToNominalDiffTime $ fromInteger normalized

-- | Wait for a given amount of time.
sleep :: NominalDiffTime -> IO ()
sleep = threadDelay . toMicroSeconds where toMicroSeconds = (1000000 *) . fromInteger . round

-- | Capitalize a Text string, first character will be uppercased
-- and the rest will be lowercased.
capitalize :: Text -> Text
capitalize text = case T.uncons text of
    Nothing     -> text
    Just (h, t) -> let lowered = T.toLower t in T.cons (C.toUpper h) lowered

-- | Send a desktop notification via DBus.
notify :: Client -> NotificationType -> Text -> Text -> Maybe FilePath -> NominalDiffTime -> IO ()
notify client nType title text icon timeout = callNoReply client params
  where
    params = (methodCall objectPath interface methodName)
        { methodCallDestination = Just "org.freedesktop.Notifications"
        , methodCallBody        = args
        }
    objectPath = "/org/freedesktop/Notifications"
    interface  = "org.freedesktop.Notifications"
    methodName = "Notify"
    appName    = "ntfd"
    appIcon    = fromMaybe "" icon
    replaceId Weather      = 1
    replaceId Mpd          = 2
    replaceId Twitch       = 3
    replaceId (Github nid) = nid
    args =
        [ toVariant (appName :: Text)
        , toVariant (replaceId nType :: Word32)
        , toVariant appIcon
        , toVariant title
        , toVariant text
        , toVariant ([] :: [String])
        , toVariant (M.fromList [] :: M.Map String Variant)
        , toVariant (toSeconds timeout :: Int32)
        ]
    toSeconds = (1000 *) . fromInteger . round
