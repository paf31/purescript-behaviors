module Main where

import FRP
import FRP.Event
import FRP.Event.Time
import FRP.Behavior

import Debug.Trace
 
time = show <$> interval 1000

main = trace `subscribe` time
