module FRP.Event.Time
  ( interval
  ) where

import FRP.Event (Event)

-- | Create an event which fires every specified number of milliseconds.
foreign import interval :: Int -> Event Int
