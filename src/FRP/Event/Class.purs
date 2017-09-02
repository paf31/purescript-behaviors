module FRP.Event.Class
  ( class IsEvent
  , fold
  , folded
  , count
  , mapAccum
  , mapMaybe
  , withLast
  , sampleOn
  , sampleOn_
  ) where

import Prelude

import Control.Alternative (class Alternative)
import Data.Maybe (Maybe(..))
import Data.Monoid (class Monoid, mempty)
import Data.Tuple (Tuple(..), snd)

-- | Functions which an `Event` type should implement, so that
-- | `Behavior`s can be defined in terms of any such event type.
class Alternative event <= IsEvent event where
  -- | Combine incoming values using the specified function,
  -- | starting with the specific initial value.
  fold :: forall a b. (a -> b -> b) -> event a -> b -> event b
  -- | Discard incoming values which do not satisfy the predicate.
  mapMaybe :: forall a b. (a -> Maybe b) -> event a -> event b
  -- | Sample an event at the times when a second event fires.
  sampleOn :: forall a b. event a -> event (a -> b) -> event b

-- | Count the number of events received.
count :: forall event a. IsEvent event => event a -> event Int
count s = fold (\_ n -> n + 1) s 0

-- | Combine subsequent events using a `Monoid`.
folded :: forall event a. IsEvent event => Monoid a => event a -> event a
folded s = fold append s mempty

-- | Compute differences between successive event values.
withLast :: forall event a. IsEvent event => event a -> event { now :: a, last :: Maybe a }
withLast e = mapMaybe id (fold step e Nothing) where
  step a Nothing           = Just { now: a, last: Nothing }
  step a (Just { now: b }) = Just { now: a, last: Just b }

-- | Map over an event with an accumulator.
-- |
-- | For example, to keep the index of the current event:
-- |
-- | ```purescript
-- | mapAccum (\x i -> Tuple (i + 1) (Tuple x i)) 0`.
-- | ```
mapAccum :: forall event a b c. IsEvent event => (a -> b -> Tuple b c) -> event a -> b -> event c
mapAccum f xs acc = mapMaybe snd
  $ fold (\a (Tuple b _) -> pure <$> f a b) xs
  $ Tuple acc Nothing

-- | Create an `Event` which samples the latest values from the first event
-- | at the times when the second event fires, ignoring the values produced by
-- | the second event.
sampleOn_ :: forall event a b. IsEvent event => event a -> event b -> event a
sampleOn_ a b = sampleOn a (b $> id)
