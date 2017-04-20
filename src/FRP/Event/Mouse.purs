module FRP.Event.Mouse
  ( move
  , down
  , up
  ) where

import FRP.Event (Event)

-- | Create an `Event` which fires when the mouse moves
foreign import move :: Event { x :: Int, y :: Int }

-- | Create an `Event` which fires when a mouse button is pressed
foreign import down :: Event Int

-- | Create an `Event` which fires when a mouse button is released
foreign import up :: Event Int
