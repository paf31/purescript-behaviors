module FRP.Event.Keyboard
  ( down
  , up
  , withKeys
  ) where

import FRP.Event (Event)

-- | Create an `Event` which fires when a key is pressed
foreign import down :: Event Int

-- | Create an `Event` which fires when a key is released
foreign import up :: Event Int

-- | Create an event which also returns the current pressed keycodes.
foreign import withKeys :: forall a. Event a -> Event { value :: a, keys :: Array Int }
