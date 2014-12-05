module FRP.Event.Time
  ( interval
  ) where

import FRP.Event

foreign import interval """
  function interval(n) {
    return Behavior.Event.interval(n);
  }
  """ :: Number -> Event Number 
