module FRP.Behavior.Time
  ( instant
  , seconds
  ) where

import Prelude

import Data.DateTime.Instant (Instant, unInstant)
import Data.Time.Duration (Seconds, toDuration)
import FRP.Behavior (Behavior, behavior)
import FRP.Event.Time (withTime)

-- | Get the current time in milliseconds since the epoch.
instant :: Behavior Instant
instant = behavior \e -> map (\{ value, time: t } -> value t) (withTime e)

-- | Get the current time in seconds since the epoch.
seconds :: Behavior Seconds
seconds = map (toDuration <<< unInstant) instant
