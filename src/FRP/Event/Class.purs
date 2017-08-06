module FRP.Event.Class
  ( class IsEvent
  , fold
  , folded
  , count
  , mapMaybe
  , withLast
  , sampleOn
  , sampleOn_
  ) where

import Prelude

import Control.Alternative (class Alternative)
import Data.Maybe (Maybe(..))
import Data.Monoid (class Monoid, mempty)

-- | Functions which an `Event` type should implement, so that
-- | `Behavior`s can be defined in terms of any such event type.
class Alternative event <= IsEvent event where
  fold :: forall a b. (a -> b -> b) -> event a -> b -> event b

  mapMaybe :: forall a b. (a -> Maybe b) -> event a -> event b

  sampleOn :: forall a b. event a -> event (a -> b) -> event b

-- | Count the number of events received.
count :: forall event a. IsEvent event => event a -> event Int
count s = fold (\_ n -> n + 1) s 0

-- | Count the number of events received.
folded :: forall event a. IsEvent event => Monoid a => event a -> event a
folded s = fold append s mempty

-- | Compute differences between successive event values.
withLast :: forall event a. IsEvent event => event a -> event { now :: a, last :: Maybe a }
withLast e = mapMaybe id (fold step e Nothing) where
  step a Nothing           = Just { now: a, last: Nothing }
  step a (Just { now: b }) = Just { now: a, last: Just b }

-- | Create an `Event` which samples the latest values from the first event
-- | at the times when the second event fires, ignoring the values produced by
-- | the second event.
sampleOn_ :: forall event a b. IsEvent event => event a -> event b -> event a
sampleOn_ a b = sampleOn a (b $> id)
