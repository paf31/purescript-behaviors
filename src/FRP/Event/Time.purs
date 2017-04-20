module FRP.Event.Time
  ( interval
  , withTime
  ) where

import FRP.Event (Event)

-- | Create an event which fires every specified number of milliseconds.
foreign import interval :: Int -> Event Int

-- | Create an event which reports the current time in milliseconds since the epoch.
foreign import withTime :: forall a. Event a -> Event { value :: a, time :: Int }
