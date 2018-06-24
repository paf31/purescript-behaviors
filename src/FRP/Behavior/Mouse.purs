module FRP.Behavior.Mouse
  ( position
  , buttons
  ) where

import Prelude

import Data.Maybe (Maybe)
import Data.Set as Set
import FRP.Behavior (Behavior, behavior)
import FRP.Event.Mouse (Mouse, withPosition, withButtons)

-- | A `Behavior` which reports the current mouse position, if it is known.
position :: Mouse -> Behavior (Maybe { x :: Int, y :: Int })
position m = behavior \e -> map (\{ value, pos } -> value pos) (withPosition m e)

-- | A `Behavior` which reports the mouse buttons which are currently pressed.
buttons :: Mouse -> Behavior (Set.Set Int)
buttons m = behavior \e -> map (\{ value, buttons: bs } -> value bs) (withButtons m e)
