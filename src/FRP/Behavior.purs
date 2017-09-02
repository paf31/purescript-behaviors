module FRP.Behavior
  ( Behavior
  , ABehavior
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
import FRP.Event (class IsEvent, Event, create, fold, sampleOn, subscribe, withLast)
import FRP.Event.Time (animationFrame)

-- | The more general type of `ABehavior`, which is parameterized over some underlying
-- | `event` type.
-- |
-- | Normally, you should use `ABehavior` instead, but this type
-- | can also be used with other types of events, including the ones in the
-- | `Semantic` module.
newtype ABehavior event a = ABehavior (forall b. event (a -> b) -> event b)

-- | A `ABehavior` acts like a continuous function of time.
-- |
-- | We can construct a sample a `ABehavior` from some `Event`, combine `ABehavior`s
-- | using `Applicative`, and sample a final `ABehavior` on some other `Event`.
type Behavior = ABehavior Event

instance functorABehavior :: Functor event => Functor (ABehavior event) where
  map f (ABehavior b) = ABehavior \e -> b (map (_ <<< f) e)

instance applyABehavior :: Functor event => Apply (ABehavior event) where
  apply (ABehavior f) (ABehavior a) = ABehavior \e -> a (f (compose <$> e))

instance applicativeABehavior :: Functor event => Applicative (ABehavior event) where
  pure a = ABehavior \e -> applyFlipped a <$> e

instance semigroupABehavior :: (Functor event, Semigroup a) => Semigroup (ABehavior event a) where
  append = lift2 append

instance monoidABehavior :: (Functor event, Monoid a) => Monoid (ABehavior event a) where
  mempty = pure mempty

-- | Construct a `Behavior` from its sampling function.
behavior :: forall event a. (forall b. event (a -> b) -> event b) -> ABehavior event a
behavior = ABehavior

-- | Create a `Behavior` which is updated when an `Event` fires, by providing
-- | an initial value.
step :: forall event a. IsEvent event => a -> event a -> ABehavior event a
step a e = ABehavior (sampleOn (pure a `alt` e))

-- | Create a `Behavior` which is updated when an `Event` fires, by providing
-- | an initial value and a function to combine the current value with a new event
-- | to create a new value.
unfold :: forall event a b. IsEvent event => (a -> b -> b) -> event a -> b -> ABehavior event b
unfold f e a = step a (fold f e a)

-- | Sample a `Behavior` on some `Event`.
sample :: forall event a b. ABehavior event a -> event (a -> b) -> event b
sample (ABehavior b) e = b e

-- | Sample a `Behavior` on some `Event` by providing a combining function.
sampleBy :: forall event a b c. IsEvent event => (a -> b -> c) -> ABehavior event a -> event b -> event c
sampleBy f b e = sample (map f b) (map applyFlipped e)

-- | Sample a `Behavior` on some `Event`, discarding the event's values.
sample_ :: forall event a b. IsEvent event => ABehavior event a -> event b -> event a
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
integral
  :: forall event a t
   . IsEvent event
  => Field t
  => Semiring a
  => (((a -> t) -> t) -> a)
  -> a
  -> ABehavior event t
  -> ABehavior event a
  -> ABehavior event a
integral g initial t b =
    ABehavior \e ->
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
integral'
  :: forall event t
   . IsEvent event
  => Field t
  => t
  -> ABehavior event t
  -> ABehavior event t
  -> ABehavior event t
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
derivative
  :: forall event a t
   . IsEvent event
  => Field t
  => Ring a
  => (((a -> t) -> t) -> a)
  -> ABehavior event t
  -> ABehavior event a
  -> ABehavior event a
derivative g t b =
    ABehavior \e ->
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
derivative'
  :: forall event t
   . IsEvent event
  => Field t
  => ABehavior event t
  -> ABehavior event t
  -> ABehavior event t
derivative' = derivative (_ $ id)

-- | Compute a fixed point
fixB :: forall a. a -> (ABehavior Event a -> ABehavior Event a) -> ABehavior Event a
fixB a f = behavior \s -> unsafePerformEff do
  { event, push } <- create
  let b = f (step a event)
  subscribe (sample_ b s) push
  pure (sampleOn event s)

-- | Animate a `Behavior` by providing a rendering function.
animate
  :: forall scene eff
   . ABehavior Event scene
  -> (scene -> Eff (frp :: FRP | eff) Unit)
  -> Eff (frp :: FRP | eff) Unit
animate scene render = subscribe (sample_ scene animationFrame) render
