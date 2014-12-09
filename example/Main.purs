module Main where

import FRP
import FRP.Event
import FRP.Event.Time
import FRP.Behavior

import Control.Monad.Eff

foreign import display 
  "function display(s) {\
  \  return function() {\
  \    document.body.innerText = s;\
  \  };\
  \}" :: forall eff. String -> Eff eff Unit

every :: Number -> Event Number
every n = count (interval n)

tick :: Number -> Number -> Behavior Number
tick n max = (\n -> n % max) <$> step 0 (every n)

time :: Behavior String
time = toTime <$> tick cents  100
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

main = display `subscribe` (sample' time (every 20))
