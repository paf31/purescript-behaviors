module FRP.Event.Time
  ( interval
  , animationFrame
  , withTime
  ) where

import Prelude ((<<<), const, map)
import Data.Filterable (filtered)
import Data.Maybe (Maybe(..))
import Data.Unit (Unit)
import FRP.Event (Event)
import FRP.Event.Class (sampleOn)

-- | Create an event which fires every specified number of milliseconds.
foreign import interval :: Int -> Event Int

-- | Create an event which fires every frame (using `requestAnimationFrame`).
foreign import animationFrame :: Event Unit

-- | Create an event which reports the current time in milliseconds since the epoch.
foreign import withTime :: forall a. Event a -> Event { value :: a, time :: Number }

-- | Sample the events that are fired while a boolean event is true.
gate :: forall a. Event Boolean -> Event a -> Event a
gate = gateBy const

-- | Generalised form of `gateBy`, allowing for any predicate between
-- | the two events. When true, the second event is sampled.
gateBy
  :: forall a b.
     (a -> b -> Boolean)
  -> Event a
  -> Event b
  -> Event b
gateBy f s
   = filtered
 <<< sampleOn s
 <<< map \x p -> if f p x then Just x else Nothing
