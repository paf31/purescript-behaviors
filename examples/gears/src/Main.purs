module Main where

import Data.Maybe
import FRP
import Math
import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Control.Plus ((<|>))
import FRP.Behavior (behavior, sample_, step)
import FRP.Event (Event, subscribe)

newtype Id = Id String
newtype Direction = Direction String

foreign import create :: forall eff a . Eff (frp :: FRP | eff) { event :: Event a , push :: a -> Eff (frp :: FRP | eff) Unit}
foreign import rotate :: ∀ eff.  Id -> Direction -> Eff eff Unit
foreign import attachEvents :: forall a b eff.  Id ->  (b ->  Eff (frp::FRP | eff) Unit) -> Unit

rotateAll = do
  rotate (Id "hex1") (Direction "clockwise")
  rotate (Id "hex2") (Direction "anti-clockwise")
  rotate (Id "hex3") (Direction "clockwise")

stopAll = do
  rotate (Id "hex1") (Direction "stop")
  rotate (Id "hex2") (Direction "stop")
  rotate (Id "hex3") (Direction "stop")

getSig id = do
  o <- create
  let behavior = step true o.event
  let x = attachEvents id o.push
  pure $ {behavior : behavior , event : o.event}

runSystem :: Boolean -> Boolean -> Boolean -> Boolean
runSystem a b c = a && b && c

main = do
  sig1 <- getSig (Id "hex1")
  sig2 <- getSig (Id "hex2")
  sig3 <- getSig (Id "hex3")

  let behavior = runSystem <$> sig1.behavior <*> sig2.behavior <*> sig3.behavior
  sample_ behavior (sig1.event <|> sig2.event <|> sig3.event) `subscribe` (\x -> if x then
                                                                                   rotateAll
                                                                                 else
                                                                                   stopAll)
