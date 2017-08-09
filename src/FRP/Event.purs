module FRP.Event
  ( Event
  , fold
  , never
  , filter
  , mapMaybe
  , count
  , folded
  , withLast
  , sampleOn
  , sampleOn_
  , subscribe
  , create
  ) where

import Prelude

import Control.Alternative (class Alt, class Alternative, class Plus)
import Control.Apply (lift2)
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe(..), fromJust, isJust)
import Data.Monoid (class Monoid, mempty)
import Data.Tuple (Tuple(..), snd)
import FRP (FRP)
import Partial.Unsafe (unsafePartial)

-- | An `Event` represents a collection of discrete occurrences with associated
-- | times. Conceptually, an `Event` is a (possibly-infinite) list of values-and-times:
-- |
-- | ```purescript
-- | type Event a = List { value :: a, time :: Time }
-- | ```
-- |
-- | Events are created from real events like timers or mouse clicks, and then
-- | combined using the various functions and instances provided in this module.
-- |
-- | Events are consumed by providing a callback using the `subscribe` function.
data Event a

foreign import pureImpl :: forall a. a -> Event a

foreign import mapImpl :: forall a b. (a -> b) -> Event a -> Event b

foreign import mergeImpl :: forall a. Event a -> Event a -> Event a

foreign import never :: forall a. Event a

instance functorEvent :: Functor Event where
  map = mapImpl

instance applyEvent :: Apply Event where
  apply = applyImpl

instance applicativeEvent :: Applicative Event where
  pure = pureImpl

instance altEvent :: Alt Event where
  alt = mergeImpl

instance plusEvent :: Plus Event where
  empty = never

instance alternativeEvent :: Alternative Event

instance semigroupEvent :: Semigroup a => Semigroup (Event a) where
  append = lift2 append

instance monoidEvent :: Monoid a => Monoid (Event a) where
  mempty = pure mempty

-- | Create an `Event` which combines with the latest values from two other events.
foreign import applyImpl :: forall a b. Event (a -> b) -> Event a -> Event b

-- | Fold over values received from some `Event`, creating a new `Event`.
foreign import fold :: forall a b. (a -> b -> b) -> Event a -> b -> Event b

-- | Map over an event, but carry an accumulator value with you. This can be
-- | pretty useful if, for example, you want to attach IDs to events:
-- | `mapWithAccum (\x i -> Tuple (i + 1) (Tuple x i)) 0`.
mapWithAccum :: forall a b c. (a -> b -> Tuple b c) -> Event a -> b -> Event c
mapWithAccum f xs acc = mapMaybe snd
  $ fold (\a (Tuple b _) -> pure <$> f a b) xs
  $ Tuple acc Nothing

-- | Count the number of events received.
count :: forall a. Event a -> Event Int
count s = fold (\_ n -> n + 1) s 0

-- | Count the number of events received.
folded :: forall a. Monoid a => Event a -> Event a
folded s = fold append s mempty

-- | Compute differences between successive event values.
withLast :: forall a. Event a -> Event { now :: a, last :: Maybe a }
withLast e = mapMaybe id (fold step e Nothing) where
  step a Nothing           = Just { now: a, last: Nothing }
  step a (Just { now: b }) = Just { now: a, last: Just b }

-- | Create an `Event` which only fires when a predicate holds.
foreign import filter :: forall a. (a -> Boolean) -> Event a -> Event a

-- | Filter out any `Nothing` events.
mapMaybe :: forall a b. (a -> Maybe b) -> Event a -> Event b
mapMaybe f = unsafePartial (map fromJust <<< filter isJust <<< map f)

-- | Create an `Event` which samples the latest values from the first event
-- | at the times when the second event fires.
foreign import sampleOn :: forall a b. Event a -> Event (a -> b) -> Event b

-- | Create an `Event` which samples the latest values from the first event
-- | at the times when the second event fires, ignoring the values produced by
-- | the second event.
sampleOn_ :: forall a b. Event a -> Event b -> Event a
sampleOn_ a b = sampleOn a (b $> id)

-- | Subscribe to an `Event` by providing a callback.
foreign import subscribe
  :: forall eff a r
   . Event a
  -> (a -> Eff (frp :: FRP | eff) r)
  -> Eff (frp :: FRP | eff) Unit

-- | Create an event and a function which supplies a value to that event.
foreign import create
  :: forall eff a
   . Eff (frp :: FRP | eff)
         { event :: Event a
         , push :: a -> Eff (frp :: FRP | eff) Unit
         }
