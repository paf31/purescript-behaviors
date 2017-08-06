module FRP.Behavior.Time
  ( millisSinceEpoch
  ) where

import Prelude

import FRP.Behavior (Behavior, behavior)
import FRP.Event (Event)
import FRP.Event.Time (withTime)

-- | Get the current time in milliseconds since the epoch.
millisSinceEpoch :: Behavior Event Int
millisSinceEpoch = behavior \e -> map (\{ value, time: t } -> value t) (withTime e)
