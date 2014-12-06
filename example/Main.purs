module Main where

import FRP
import FRP.Event
import FRP.Event.Time
import FRP.Behavior

import Control.Monad.Eff

foreign import display """
  function display(s) {
    return function() {
      document.body.innerText = s;
    };
  }
  """ :: forall eff. String -> Eff eff Unit

every :: Number -> Event Number
every n = fold (\_ n -> n + 1) (interval n) 0

tick :: Number -> Behavior Number
tick n = step 0 (every n)

time = toTime <$> tick millis
              <*> tick seconds
              <*> tick minutes
              <*> tick hours
  where
  millis = 1
  seconds = 1000
  minutes = seconds * 60
  hours = minutes * 60

  toTime ms ss mm hh = show hh <> ":" <> 
                       show mm <> ":" <> 
                       show ss <> "." <> 
                       show ms

main = display `subscribe` (sample' time (every 20))
