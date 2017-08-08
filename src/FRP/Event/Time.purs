module FRP.Event.Time
  ( interval
  , animationFrame
  , withTime
  ) where

import Prelude ((<$>), (-))
import Data.Tuple (Tuple(..))
import Data.Unit (Unit)
import FRP.Event (Event, sampleOn_)

-- | Create an event which fires every specified number of milliseconds.
foreign import interval :: Int -> Event Int

-- | Create an event which fires every frame (using `requestAnimationFrame`).
foreign import animationFrame :: Event Unit

-- | Create an event which reports the current time in milliseconds since the epoch.
foreign import withTime :: forall a. Event a -> Event { value :: a, time :: Int }

-- | Similar to `sampleOn_`, except that the returned `Event` is a `Tuple` of
-- | the sampled value _as well as_ the time since that value was pushed to the
-- | stream (in milliseconds).
withDelay :: forall a b. Event a -> Event b -> Event (Tuple Int a)
withDelay e sampler = go <$> stream
  where

    -- The stream with "current" and "first" stamps.
    stream :: Event { time :: Int
                    , value :: { time :: Int
                               , value :: a } }
    stream = withTime (sampleOn_ (withTime e) sampler)

    -- Calculate a duration!
    go :: { time :: Int, value :: { time :: Int, value :: a } }
       -> Tuple Int a
    go { time: now, value: { time: start, value } } =
      Tuple (now - start) value
