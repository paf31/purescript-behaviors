module FRP.Event.Time
  ( interval
  , animationFrame
  , withTime
  , debounce
  , debounceWith
  ) where

import Data.Maybe (Maybe, maybe)
import Data.Unit (Unit)
import FRP.Event (Event)
import FRP.Event.Class (fix, gateBy)
import Prelude ((+), (<), map)

-- | Create an event which fires every specified number of milliseconds.
foreign import interval :: Int -> Event Int

-- | Create an event which fires every frame (using `requestAnimationFrame`).
foreign import animationFrame :: Event Unit

-- | Create an event which reports the current time in milliseconds since the epoch.
foreign import withTime :: forall a. Event a -> Event { value :: a, time :: Number }

-- | On each event, ignore subsequent events for a given number of milliseconds.
debounce :: forall a. Number -> Event a -> Event a
debounce period = debounceWith (map { period, value: _ })

-- | Provided an input event and transformation, block the input event for the
-- | duration of the specified period on each output.
debounceWith
  :: forall a b.
     (Event a -> Event { period :: Number, value :: b })
  -> Event a
  -> Event b
debounceWith process event
  = fix \allowed ->
      let
        processed :: Event { period :: Number, value :: b }
        processed = process allowed

        expiries :: Event Number
        expiries =
          map (\{ time, value } -> time + value)
              (withTime (map _.period processed))

        comparison :: forall r. Maybe Number -> { time :: Number | r } -> Boolean
        comparison a b = maybe true (_ < b.time) a

        unblocked :: Event { time :: Number, value :: a }
        unblocked = gateBy comparison expiries stamped
      in
        { input:  map _.value unblocked
        , output: map _.value processed
        }
  where
    stamped :: Event { time :: Number, value :: a }
    stamped = withTime event
