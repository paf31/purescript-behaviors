module FRP.Event.Time
  ( interval
  , animationFrame
  , withTime
  ) where

import Prelude ((<), (+), map, pure, Unit)
import Control.Alt ((<|>))
import FRP.Event (Event)
import FRP.Event.Class (fix, gateBy)

-- | Create an event which fires every specified number of milliseconds.
foreign import interval :: Int -> Event Int

-- | Create an event which fires every frame (using `requestAnimationFrame`).
foreign import animationFrame :: Event Unit

-- | Create an event which reports the current time in milliseconds since the epoch.
foreign import withTime :: forall a. Event a -> Event { value :: a, time :: Number }

-- | Provided an input event and transformation, block the input event for the
-- | duration of the specified period on each output.
withBlocking
  :: forall a b.
     (Event a -> Event { period :: Number, value :: b })
  -> Event a
  -> Event b
withBlocking process event
  = fix \allowed ->
      let
        processed :: Event { period :: Number, value :: b }
        processed = process allowed

        expiries :: Event Number
        expiries = pure 0.0 <|>
          map (\{ time, value } -> time + value)
              (withTime (map _.period processed))

        comparison :: forall r. Number -> { time :: Number | r } -> Boolean
        comparison a b = a < b.time

        unblocked :: Event { time :: Number, value :: a }
        unblocked = gateBy comparison expiries stamped
      in
        { input:  map _.value unblocked
        , output: map _.value processed
        }
  where
    stamped :: Event { time :: Number, value :: a }
    stamped = withTime event

-- | On each event, ignore subsequent events for a given number of milliseconds.
debounce :: forall a. Number -> Event a -> Event a
debounce period = withBlocking (map \value -> { period, value })
