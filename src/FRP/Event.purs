module FRP.Event
  ( Event
  , fold
  , never
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
import Control.MonadZero (guard)
import Data.Either (fromLeft, fromRight, isLeft, isRight)
import Data.Filterable (class Filterable, filterMap)
import Data.Functor (voidLeft)
import Data.Maybe (Maybe(..), fromJust, isJust)
import Data.Monoid (class Monoid, mempty)
import Data.Tuple (Tuple(..), fst, snd)
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

instance filterableEvent :: Filterable Event where
  filter = filter

  filterMap f = unsafePartial (map fromJust <<< filter isJust <<< map f)

  partition p xs = { yes: filter p xs, no: filter (not <<< p) xs }

  partitionMap f xs = let ys = f <$> xs in
    { left:  unsafePartial (map fromLeft  <<< filter isLeft ) ys
    , right: unsafePartial (map fromRight <<< filter isRight) ys
    }

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

-- | Count the number of events received.
count :: forall a. Event a -> Event Int
count s = fold (\_ n -> n + 1) s 0

-- | Count the number of events received.
folded :: forall a. Monoid a => Event a -> Event a
folded s = fold append s mempty

-- | Compute differences between successive event values.
withLast :: forall a. Event a -> Event { now :: a, last :: Maybe a }
withLast e = filterMap id (fold step e Nothing) where
  step a Nothing           = Just { now: a, last: Nothing }
  step a (Just { now: b }) = Just { now: a, last: Just b }

-- | Create an `Event` which only fires when a predicate holds.
foreign import filter :: forall a. (a -> Boolean) -> Event a -> Event a

-- | Create an `Event` which samples the latest values from the first event
-- | at the times when the second event fires.
foreign import sampleOn :: forall a b. Event a -> Event (a -> b) -> Event b

-- | Create an `Event` which samples the latest values from the first event
-- | at the times when the second event fires, ignoring the values produced by
-- | the second event.
sampleOn_ :: forall a b. Event a -> Event b -> Event a
sampleOn_ a b = sampleOn a (b $> id)

-- | Map over an event with an accumulator value. This can be used, for example,
-- | to attach IDs: `mapWithAccum (\x i -> Tuple (i + 1) (Tuple x i)) 0`.
mapWithAccum :: forall a b c. (a -> b -> Tuple b c) -> Event a -> b -> Event c
mapWithAccum f xs acc = filterMap snd
  $ fold (\f' -> map pure <<< f' <<< fst) (f <$> xs)
  $ Tuple acc Nothing

-- | When the first event is false, mute the second event.
when :: Event Boolean -> Event ~> Event
when predicate = filterMap id <<< lift2 (voidLeft <<< guard) predicate

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
