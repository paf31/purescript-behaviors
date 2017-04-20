module FRP.Behavior
  ( Behavior
  , behavior
  , step
  , sample
  , sampleBy
  , sample_
  , unfold
  , derivative
  , integral
  ) where

import Prelude
import Control.Alt (alt)
import Control.Apply (lift2)
import Data.Function (applyFlipped)
import Data.Maybe (Maybe(..))
import Data.Monoid (class Monoid, mempty)
import Data.Tuple (Tuple(Tuple))
import FRP.Event (Event, fold, mapMaybe, sampleOn, withLast)
import Partial.Unsafe (unsafeCrashWith)

-- | A `Behavior` acts like a continuous function of time.
-- |
-- | We can construct a sample a `Behavior` from some `Event`, combine `Behavior`s
-- | using `Applicative`, and sample a final `Behavior` on some other `Event`.
newtype Behavior a = Behavior (forall b. Event (a -> b) -> Event b)

-- | Construct a `Behavior` from its sampling function.
behavior :: forall a. (forall b. Event (a -> b) -> Event b) -> Behavior a
behavior = Behavior

-- | Create a `Behavior` which is updated when an `Event` fires, by providing
-- | an initial value.
step :: forall a. a -> Event a -> Behavior a
step a e = Behavior (sampleOn (pure a `alt` e))

-- | Create a `Behavior` which is updated when an `Event` fires, by providing
-- | an initial value and a function to combine the current value with a new event
-- | to create a new value.
unfold :: forall a b. (a -> b -> b) -> Event a -> b -> Behavior b
unfold f e a = step a (fold f e a)

-- | Sample a `Behavior` on some `Event`.
sample :: forall a b. Behavior a -> Event (a -> b) -> Event b
sample (Behavior b) e = b e

-- | Sample a `Behavior` on some `Event` by providing a combining function.
sampleBy :: forall a b c. (a -> b -> c) -> Behavior a -> Event b -> Event c
sampleBy f b e = sample (map f b) (map applyFlipped e)

-- | Sample a `Behavior` on some `Event`, discarding the event's values.
sample_ :: forall a b. Behavior a -> Event b -> Event a
sample_ = sampleBy const

-- | Integrate with respect to some measure of time.
-- |
-- | This function approximates the integral using the trapezium rule at the
-- | implicit sampling interval.
integral :: forall a t. Field t => Semiring a => (t -> a -> a) -> Behavior t -> Behavior a -> Behavior a
integral mult t b =
    Behavior \e ->
      map finish (fold summing ((mapMaybe (\{ now, last } -> map (approx now) last)
        (withLast (sampleBy Tuple (Tuple <$> t <*> b) e)))) (Tuple zero Nothing))
  where
    approx :: forall b. Tuple (Tuple t a) (a -> b) -> Tuple (Tuple t a) (a -> b) -> Tuple a (Maybe (a -> b))
    approx (Tuple (Tuple t1 a1) f) (Tuple (Tuple t0 a0) _) = Tuple (mult ((t1 - t0) / two) (a0 + a1)) (Just f)

    two :: t
    two = one + one

    summing :: forall b. Tuple a (Maybe (a -> b)) -> Tuple a (Maybe (a -> b)) -> Tuple a (Maybe (a -> b))
    summing (Tuple a1 f) (Tuple a2 _) = Tuple (a1 + a2) f

    finish :: forall b. Tuple a (Maybe (a -> b)) -> b
    finish (Tuple a (Just f)) = f a
    finish _ = unsafeCrashWith "integral: no continuation"

-- | Differentiate with respect to some measure of time.
-- |
-- | This function approximates the derivative using a quotient of differences at the
-- | implicit sampling interval.
derivative :: forall a t. Field t => Ring a => (a -> t -> a) -> Behavior t -> Behavior a -> Behavior a
derivative divide t b =
    Behavior \e ->
      mapMaybe (\{ now, last } -> map (approx now) last)
        (withLast (sampleBy Tuple (Tuple <$> t <*> b) e))
  where
    approx :: forall b. Tuple (Tuple t a) (a -> b) -> Tuple (Tuple t a) (a -> b) -> b
    approx (Tuple (Tuple t1 a1) f) (Tuple (Tuple t0 a0) _) = f ((a1 - a0) `divide` (t1 - t0))

instance functorBehavior :: Functor Behavior where
  map f (Behavior b) = Behavior \e -> b (map (_ <<< f) e)

instance applyBehavior :: Apply Behavior where
  apply (Behavior f) (Behavior a) = Behavior \e -> a (f (compose <$> e))

instance applicativeBehavior :: Applicative Behavior where
  pure a = Behavior \e -> applyFlipped a <$> e

instance semigroupBehavior :: Semigroup a => Semigroup (Behavior a) where
  append = lift2 append

instance monoidBehavior :: Monoid a => Monoid (Behavior a) where
  mempty = pure mempty
