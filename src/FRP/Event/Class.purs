module FRP.Event.Class
  ( class IsEvent
  , fold
  , folded
  , count
  , mapAccum
  , withLast
  , sampleOn
  , sampleOn_
  , keepLatest
  , fix
  , gate
  , gateBy
  , module Data.Filterable
  ) where

import Prelude

import Control.Alternative (class Alternative, (<|>))
import Data.Filterable (class Filterable, filterMap, filtered)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Monoid (class Monoid, mempty)
import Data.Tuple (Tuple(..), snd)

-- | Functions which an `Event` type should implement, so that
-- | `Behavior`s can be defined in terms of any such event type:
-- |
-- | - `fold`: combines incoming values using the specified function,
-- | starting with the specific initial value.
-- | - `keepLatest` flattens a nested event, reporting values only from the
-- | most recent inner event.
-- | - `sampleOn`: samples an event at the times when a second event fires.
-- | - `fix`: compute a fixed point, by feeding output events back in as
-- | inputs.
class (Alternative event, Filterable event) <= IsEvent event where
  fold :: forall a b. (a -> b -> b) -> event a -> b -> event b
  keepLatest :: forall a. event (event a) -> event a
  sampleOn :: forall a b. event a -> event (a -> b) -> event b
  fix :: forall i o. (event i -> { input :: event i, output :: event o }) -> event o

-- | Count the number of events received.
count :: forall event a. IsEvent event => event a -> event Int
count s = fold (\_ n -> n + 1) s 0

-- | Combine subsequent events using a `Monoid`.
folded :: forall event a. IsEvent event => Monoid a => event a -> event a
folded s = fold append s mempty

-- | Compute differences between successive event values.
withLast :: forall event a. IsEvent event => event a -> event { now :: a, last :: Maybe a }
withLast e = filterMap id (fold step e Nothing) where
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
mapAccum f xs acc = filterMap snd
  $ fold (\a (Tuple b _) -> pure <$> f a b) xs
  $ Tuple acc Nothing

-- | Create an `Event` which samples the latest values from the first event
-- | at the times when the second event fires, ignoring the values produced by
-- | the second event.
sampleOn_ :: forall event a b. IsEvent event => event a -> event b -> event a
sampleOn_ a b = sampleOn a (b $> id)

-- | Sample the events that are fired while a boolean event is true. Note that,
-- | until the boolean event fires, it will be assumed to be `false`, and events
-- | will be blocked.
gate :: forall a event. IsEvent event => event Boolean -> event a -> event a
gate = gateBy (\x _ -> fromMaybe false x)

-- | Generalised form of `gateBy`, allowing for any predicate between the two
-- | events. Until a value from the first event is received, `Nothing` will be
-- | passed to the predicate.
gateBy
  :: forall a b event
   . IsEvent event
  => (Maybe a -> b -> Boolean)
  -> event a
  -> event b
  -> event b
gateBy f sampled
   = filtered
 <<< sampleOn (pure Nothing <|> (Just <$> sampled))
 <<< map \x p -> if f p x then Just x else Nothing
