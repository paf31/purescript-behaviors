module Test.Main where

import Prelude
import FRP.Behavior.Mouse as Mouse
import FRP.Behavior.Time as Time
import Color (black, lighten, white)
import Control.Monad.Eff (Eff)
import Data.Array (sortBy, (..))
import Data.Foldable (foldMap)
import Data.Int (toNumber)
import Data.Maybe (fromJust, maybe)
import Data.Set (isEmpty)
import FRP (FRP)
import FRP.Behavior (Behavior, animate, derivative', fixB, integral')
import FRP.Behavior.Mouse (buttons)
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
  scaleFactor = max w h / 16.0

  renderCircle :: Circle -> Drawing
  renderCircle { x, y, size } =
    scale scaleFactor scaleFactor <<< translate x y <<< scale size size $
      outlined
        (outlineColor (lighten (0.8 - size * 0.2) black) <> lineWidth ((1.0 + size * 2.0) / scaleFactor))
        (circle 0.0 0.0 0.5)

  renderCircles :: Array Circle -> Drawing
  renderCircles = foldMap renderCircle

  seconds :: Behavior Number
  seconds = map ((_ / 1000.0) <<< toNumber) Time.millisSinceEpoch

  -- `swell` is an interactive function of time defined by a differential equation:
  --
  -- d^2s/dt^2
  --   | mouse down = ⍺ - βs
  --   | mouse up   = ɣ - δs - ε ds/dt
  --
  -- So the function exhibits either decay or growth depending on if
  -- the mouse is pressed or not.
  --
  -- We can solve the differential equation using an integral and a fixed point.
  swell :: Behavior Number
  swell = fixB 2.0 \b ->
    let f bs s ds | isEmpty bs = -8.0 * (s - 1.0) - ds * 2.0
                  | otherwise = 2.0 * (4.0 - s) in
    integral' 2.0 seconds (integral' 0.0 seconds (f <$> buttons <*> b <*> derivative' seconds b))

  circles :: Behavior (Array Circle)
  circles = toCircles <$> Mouse.position <*> swell where
    toCircles m sw =
        sortBy (comparing (\{ x, y } -> -(dist x y m))) do
          i <- 0 .. 16
          j <- 0 .. 16
          let x = toNumber i
              y = toNumber j
              d = dist x y m
          pure { x
               , y
               , size: 0.1 + (1.0 + sw) / (d + 1.5)
               }
      where
        dist x y = maybe infinity \{ x: mx, y: my } ->
          let dx = x - toNumber mx / scaleFactor
              dy = y - toNumber my / scaleFactor
          in dx * dx + dy * dy

main :: forall eff. Eff (canvas :: CANVAS, frp :: FRP | eff) Unit
main = do
  mcanvas <- getCanvasElementById "canvas"
  let canvas = unsafePartial (fromJust mcanvas)
  ctx <- getContext2D canvas
  w <- getCanvasWidth canvas
  h <- getCanvasHeight canvas
  _ <- setCanvasWidth w canvas
  _ <- setCanvasHeight h canvas
  animate (scene { w, h }) (render ctx)
