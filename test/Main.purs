module Test.Main where

import Prelude
import FRP.Behavior.Keyboard as Keyboard
import FRP.Behavior.Mouse as Mouse
import FRP.Behavior.Time as Time
import Control.Monad.Eff (Eff)
import Data.Array (fromFoldable, length)
import Data.Foldable (fold)
import Data.Int (toNumber)
import Data.Maybe (maybe)
import Data.Tuple (Tuple(..))
import FRP (FRP)
import FRP.Behavior (Behavior, sample_, derivative, integral)
import FRP.Event (subscribe)
import FRP.Event.Time (interval)

foreign import display :: forall eff. String -> Eff eff Unit

mouse :: Behavior (Tuple Int Int)
mouse = maybe (Tuple 0 0) (\{ x, y } -> Tuple x y) <$> Mouse.position

all :: Behavior String
all = fold
  [ pure "millisSinceEpoch: "
  , map show Time.millisSinceEpoch
  , pure "\nmouse: "
  , map show mouse
  , pure "\nbuttons: "
  , map (show <<< fromFoldable) Mouse.buttons
  , pure "\nkeys: "
  , map (show <<< fromFoldable) Keyboard.keys
  , pure "\nintegral: "
  , map show (integral' buttonCount)
  , pure "\nderivative: "
  , map show (derivative div2 (map ((_ / 1000.0) <<< toNumber) Time.millisSinceEpoch) (map (\(Tuple x y) -> Tuple (toNumber x) (toNumber y)) mouse))
  ]

div2 :: Tuple Number Number -> Number -> Tuple Number Number
div2 (Tuple x y) z = Tuple (x / z) (y / z)

buttonCount :: Behavior Number
buttonCount = map (toNumber <<< length <<< fromFoldable) Mouse.buttons

integral' :: Behavior Number -> Behavior Number
integral' = integral mul (map ((_ / 1000.0) <<< toNumber) Time.millisSinceEpoch)

main :: forall eff. Eff (frp :: FRP | eff) Unit
main = sample_ all (interval 50) `subscribe` display
