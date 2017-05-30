module FRP.Event.Time
  ( interval
  , animationFrame
  , withTime
  ) where

import Data.Unit (Unit)
import FRP.Event (Event)

-- | Create an event which fires every specified number of milliseconds.
foreign import interval :: Int -> Event Int

-- | Create an event which fires every frame (using `requestAnimationFrame`).
foreign import animationFrame :: Event Unit

-- | Create an event which reports the current time in milliseconds since the epoch.
foreign import withTime :: forall a. Event a -> Event { value :: a, time :: Int }
