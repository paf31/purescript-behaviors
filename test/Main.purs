module Test.Main where

import Prelude
import FRP.Behavior.Mouse as Mouse
import FRP.Behavior.Time as Time
import Color (black, lighten, white)
import Control.Monad.Eff (Eff)
import Data.Array ((..))
import Data.Foldable (foldMap)
import Data.Int (toNumber)
import Data.Maybe (fromJust, maybe)
import Data.Traversable (sequence)
import Data.Tuple (Tuple(..))
import FRP (FRP)
import FRP.Behavior (Behavior, derivative, sample_)
import FRP.Event (subscribe)
import FRP.Event.Time (interval)
import Global (infinity)
import Graphics.Canvas (CANVAS, getCanvasElementById, getCanvasHeight, getCanvasWidth, getContext2D, setCanvasHeight, setCanvasWidth)
import Graphics.Drawing (Drawing, circle, fillColor, filled, lineWidth, outlineColor, outlined, rectangle, render, scale, translate)
import Partial.Unsafe (unsafePartial)

type Circle = { x :: Number, y :: Number, size :: Number }

scene :: { w :: Number, h :: Number } -> Behavior Drawing
scene { w, h } = pure background <> map renderCircles circles where
  background :: Drawing
  background = filled (fillColor white) (rectangle 0.0 0.0 w h)

  scaleFactor :: Number
  scaleFactor = max w h / 10.0

  renderCircle :: Circle -> Drawing
  renderCircle { x, y, size } =
    scale scaleFactor scaleFactor <<< translate x y <<< scale size size $
      outlined
        (outlineColor (lighten (0.8 - size * 0.2) black) <> lineWidth ((1.0 + size * 2.0) / scaleFactor))
        (circle 0.0 0.0 0.5)

  renderCircles :: Array Circle -> Drawing
  renderCircles = foldMap renderCircle

  mouse :: Behavior (Tuple Number Number)
  mouse = maybe (Tuple 0.0 0.0) (\{ x, y } -> Tuple (toNumber x) (toNumber y)) <$> Mouse.position

  seconds :: Behavior Number
  seconds = map ((_ / 1000.0) <<< toNumber) Time.millisSinceEpoch

  speed :: Behavior Number
  speed =
    map (\(Tuple dx dy) -> (dx * dx + dy * dy) / scaleFactor / scaleFactor) $
      derivative
        (\(Tuple x y) z -> Tuple (x / z) (y / z))
        seconds
        mouse

  circles :: Behavior (Array Circle)
  circles = sequence do
    i <- 0 .. 10
    j <- 0 .. 10
    let x = toNumber i
        y = toNumber j
        toCircle (Tuple mx my) s =
          let dx = x - mx / scaleFactor
              dy = y - my / scaleFactor
          in { x
             , y
             , size: 0.5 + (1.0 + s / 200.0) / (dx * dx + dy * dy + 1.5)
             }
    pure (toCircle <$> mouse <*> speed)

main :: forall eff. Eff (canvas :: CANVAS, frp :: FRP | eff) Unit
main = do
  mcanvas <- getCanvasElementById "canvas"
  let canvas = unsafePartial (fromJust mcanvas)
  ctx <- getContext2D canvas
  w <- getCanvasWidth canvas
  h <- getCanvasHeight canvas
  _ <- setCanvasWidth w canvas
  _ <- setCanvasHeight h canvas
  sample_ (scene { w, h }) (interval 80) `subscribe` render ctx
