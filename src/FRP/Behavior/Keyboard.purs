module FRP.Behavior.Keyboard
  ( keys
  , key
  ) where

import Prelude

import Data.Set as Set
import FRP.Behavior (Behavior, behavior)
import FRP.Event.Keyboard (Keyboard, withKeys)

-- | A `Behavior` which reports the keys which are currently pressed.
keys :: Keyboard -> Behavior (Set.Set String)
keys keyboard = behavior \e -> map (\{ value, keys: ks } -> value (Set.fromFoldable ks)) (withKeys keyboard e)

-- | A `Behavior` which reports whether a specific key is currently pressed.
key :: Keyboard -> String -> Behavior Boolean
key keyboard k = Set.member k <$> keys keyboard
