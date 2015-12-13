module FRP.Event.Time
  ( interval
  ) where

import FRP.Event

foreign import interval :: Int -> Event Int
