module FRP.Event.Mouse
  ( move
  , down
  , up
  , withPosition
  , withButtons
  ) where

import Data.Nullable (Nullable)
import FRP.Event (Event)

-- | Create an `Event` which fires when the mouse moves
foreign import move :: Event { x :: Int, y :: Int }

-- | Create an event which also returns the current mouse position.
foreign import withPosition :: forall a. Event a -> Event { value :: a, pos :: Nullable { x :: Int, y :: Int } }

-- | Create an `Event` which fires when a mouse button is pressed
foreign import down :: Event Int

-- | Create an `Event` which fires when a mouse button is released
foreign import up :: Event Int

-- | Create an event which also returns the current mouse buttons.
foreign import withButtons :: forall a. Event a -> Event { value :: a, buttons :: Array Int }
