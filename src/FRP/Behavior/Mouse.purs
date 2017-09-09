module FRP.Behavior.Mouse
  ( position
  , buttons
  ) where

import Prelude

import Data.Maybe (Maybe)
import Data.Nullable (toMaybe)
import Data.Set as Set
import FRP.Behavior (Behavior, behavior)
import FRP.Event.Mouse (withPosition, withButtons)

-- | A `Behavior` which reports the current mouse position, if it is known.
position :: Behavior (Maybe { x :: Int, y :: Int })
position = behavior \e -> map (\{ value, pos } -> value (toMaybe pos)) (withPosition e)

-- | A `Behavior` which reports the mouse buttons which are currently pressed.
buttons :: Behavior (Set.Set Int)
buttons = behavior \e -> map (\{ value, buttons: bs } -> value (Set.fromFoldable bs)) (withButtons e)
