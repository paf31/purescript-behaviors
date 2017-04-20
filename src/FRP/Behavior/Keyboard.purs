module FRP.Behavior.Keyboard
  ( keys
  ) where

import Prelude
import Control.Alt ((<|>))
import Data.Set as Set
import FRP.Behavior (Behavior, unfold)
import FRP.Event.Keyboard (up, down)

-- | A `Behavior` which reports the keys which are currently pressed.
keys :: Behavior (Set.Set Int)
keys = unfold id (Set.insert <$> down <|> Set.delete <$> up) Set.empty
