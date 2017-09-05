module FRP.Event
  ( Event
  , never
  , subscribe
  , create
  , module Class
  ) where

import Prelude

import Control.Alternative (class Alt, class Alternative, class Plus)
import Control.Apply (lift2)
import Control.Monad.Eff (Eff)
import Data.Filterable (class Filterable)
import Data.Either (fromLeft, isLeft, fromRight, isRight)
import Data.Maybe (Maybe, fromJust, isJust)
import Data.Monoid (class Monoid, mempty)
import Data.Tuple (Tuple(..), fst, snd)
import FRP (FRP)
import FRP.Event.Class as Class
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

instance eventIsEvent :: Class.IsEvent Event where
  fold = fold
  sampleOn = sampleOn

-- | Create an `Event` which combines with the latest values from two other events.
foreign import applyImpl :: forall a b. Event (a -> b) -> Event a -> Event b

-- | Fold over values received from some `Event`, creating a new `Event`.
foreign import fold :: forall a b. (a -> b -> b) -> Event a -> b -> Event b

-- | Create an `Event` which only fires when a predicate holds.
foreign import filter :: forall a. (a -> Boolean) -> Event a -> Event a

-- | Create an `Event` which samples the latest values from the first event
-- | at the times when the second event fires.
foreign import sampleOn :: forall a b. Event a -> Event (a -> b) -> Event b

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
