module FRP.Behavior.Mouse
  ( position
  , buttons
  ) where

import Prelude

import Control.Alt ((<|>))
import Data.Maybe (Maybe(..))
import Data.Set as Set
import FRP.Behavior (Behavior, step, unfold)
import FRP.Event.Mouse (move, up, down)

-- | A `Behavior` which reports the current mouse position, if it is known.
position :: Behavior (Maybe { x :: Int, y :: Int })
position = step Nothing (map Just move)

-- | A `Behavior` which reports the mouse buttons which are currently pressed.
buttons :: Behavior (Set.Set Int)
buttons = unfold id (Set.insert <$> down <|> Set.delete <$> up) Set.empty
