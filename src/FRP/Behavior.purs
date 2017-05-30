module FRP.Behavior
  ( Behavior
  , behavior
  , step
  , sample
  , sampleBy
  , sample_
  , unfold
  , integral
  , integral'
  , derivative
  , derivative'
  , fixB
  , animate
  ) where

import Prelude
import Control.Alt (alt)
import Control.Apply (lift2)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Data.Function (applyFlipped)
import Data.Maybe (Maybe(..))
import Data.Monoid (class Monoid, mempty)
import Data.Tuple (Tuple(Tuple))
import FRP (FRP)
import FRP.Event (Event, create, fold, sampleOn, subscribe, withLast)
import FRP.Event.Time (animationFrame)

-- | A `Behavior` acts like a continuous function of time.
-- |
-- | We can construct a sample a `Behavior` from some `Event`, combine `Behavior`s
-- | using `Applicative`, and sample a final `Behavior` on some other `Event`.
newtype Behavior a = Behavior (forall b. Event (a -> b) -> Event b)

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
-- |
-- | The `Semiring` `a` should be a vector field over the field `t`. To represent
-- | this, the user should provide a _grate_ which lifts a multiplication
-- | function on `t` to a function on `a`. Simple examples where `t ~ a` can use
-- | the `integral'` function instead.
integral :: forall a t. Field t => Semiring a => (((a -> t) -> t) -> a) -> a -> Behavior t -> Behavior a -> Behavior a
integral g initial t b =
    Behavior \e ->
      let x = sample b (e $> id)
          y = withLast (sampleBy Tuple t x)
          z = fold approx y initial
      in e <*> z
  where
    approx { last: Nothing } s = s
    approx { now: Tuple t1 a1, last: Just (Tuple t0 a0) } s = s + g (\f -> f (a0 + a1) * (t1 - t0) / two)

    two :: t
    two = one + one

-- | Integrate with respect to some measure of time.
-- |
-- | This function is a simpler version of `integral` where the function being
-- | integrated takes values in the same field used to represent time.
integral' :: forall t. Field t => t -> Behavior t -> Behavior t -> Behavior t
integral' = integral (_ $ id)

-- | Differentiate with respect to some measure of time.
-- |
-- | This function approximates the derivative using a quotient of differences at the
-- | implicit sampling interval.
-- |
-- | The `Semiring` `a` should be a vector field over the field `t`. To represent
-- | this, the user should provide a grate which lifts a division
-- | function on `t` to a function on `a`. Simple examples where `t ~ a` can use
-- | the `derivative'` function.
derivative :: forall a t. Field t => Ring a => (((a -> t) -> t) -> a) -> Behavior t -> Behavior a -> Behavior a
derivative g t b =
    Behavior \e ->
      let x = sample b (e $> id)
          y = withLast (sampleBy Tuple t x)
          z = map approx y
      in e <*> z
  where
    approx { last: Nothing } = zero
    approx { now: Tuple t1 a1, last: Just (Tuple t0 a0) } = g (\f -> f (a1 - a0) / (t1 - t0))

-- | Differentiate with respect to some measure of time.
-- |
-- | This function is a simpler version of `derivative` where the function being
-- | differentiated takes values in the same field used to represent time.
derivative' :: forall t. Field t => Behavior t -> Behavior t -> Behavior t
derivative' = derivative (_ $ id)

-- | Compute a fixed point
fixB :: forall a. Show a => a -> (Behavior a -> Behavior a) -> Behavior a
fixB a f = behavior \s -> unsafePerformEff do
  { event, push } <- create
  let b = f (step a event)
  subscribe (sample_ b s) push
  pure (sampleOn event s)

-- | Animate a `Behavior` by providing a rendering function.
animate
  :: forall scene eff
   . Behavior scene
  -> (scene -> Eff (frp :: FRP | eff) Unit)
  -> Eff (frp :: FRP | eff) Unit
animate scene render = subscribe (sample_ scene animationFrame) render
