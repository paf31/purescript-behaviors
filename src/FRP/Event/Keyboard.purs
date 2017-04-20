module FRP.Event.Keyboard
  ( down
  , up
  ) where

import FRP.Event (Event)

-- | Create an `Event` which fires when a key is pressed
foreign import down :: Event Int

-- | Create an `Event` which fires when a key is released
foreign import up :: Event Int
