module FRP.Behavior.Time
  ( millisSinceEpoch
  , seconds
  ) where

import Prelude

import FRP.Behavior (Behavior, behavior)
import FRP.Event.Time (withTime)

-- | Get the current time in milliseconds since the epoch.
millisSinceEpoch :: Behavior Number
millisSinceEpoch = behavior \e -> map (\{ value, time: t } -> value t) (withTime e)

-- | Get the current time in seconds since the epoch.
seconds :: Behavior Number
seconds = map (_ / 1000.0) millisSinceEpoch
