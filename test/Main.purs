module Test.Main where

import Prelude

import Control.Monad.Eff (Eff)
import FRP (FRP)
import FRP.Behavior (Behavior, sample', step)
import FRP.Event (Event, subscribe, count)
import FRP.Event.Time (interval)

foreign import display :: forall eff. String -> Eff eff Unit

every :: Int -> Event Int
every n = count (interval n)

tick :: Int -> Int -> Behavior Int
tick n max = (\m -> m `mod` max) <$> step 0 (every n)

time :: Behavior String
time =
    toTime <$> tick cents  100
           <*> tick seconds 60
           <*> tick minutes 60
           <*> tick hours   24
  where
    cents = 10
    seconds = 1000
    minutes = seconds * 60
    hours = minutes * 60

    toTime cs ss mm hh = pad hh <> ":" <>
                         pad mm <> ":" <>
                         pad ss <> "." <>
                         pad cs

    pad n | n < 10 = "0" <> show n
          | otherwise = show n

main :: forall eff. Eff (frp :: FRP | eff) Unit
main = display `subscribe` (sample' time (every 20))
