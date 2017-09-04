module FRP.Behavior.Keyboard
  ( keys
  , key
  ) where

import Prelude

import Data.Set as Set
import FRP.Behavior (Behavior, behavior)
import FRP.Event.Keyboard (withKeys)

-- | A `Behavior` which reports the keys which are currently pressed.
keys :: Behavior (Set.Set Int)
keys = behavior \e -> map (\{ value, keys: ks } -> value (Set.fromFoldable ks)) (withKeys e)

-- | A `Behavior` which reports whether a specific key is currently pressed.
key :: Int -> Behavior Boolean
key k = Set.member k <$> keys
