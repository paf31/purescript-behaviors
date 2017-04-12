module FRP.Behavior
  ( Behavior
  , step
  , sample
  , sample'
  ) where

import Prelude
import FRP.Event (Event)

-- | A `Behavior` acts like a continuous function of time.
-- |
-- | We can construct a sample a `Behavior` from some `Event`, combine `Behavior`s
-- | using `Applicative`, and sample a final `Behavior` on some other `Event`.
newtype Behavior a = Behavior (forall b. Event (a -> b) -> Event b)

-- | Create a `Behavior` which is updated when an `Event` fires, by providing
-- | an initial value.
step :: forall a. a -> Event a -> Behavior a
step a e = Behavior \f -> f <*> (pure a <> e)

-- | Sample a `Behavior` on some `Event`.
sample :: forall a b c. (a -> b -> c) -> Behavior a -> Event b -> Event c
sample f (Behavior b) e = b (flip f <$> e)

-- | Sample a `Behavior` on some `Event`, discarding the event's payload.
sample' :: forall a b. Behavior a -> Event b -> Event a
sample' = sample const

instance functorBehavior :: Functor Behavior where
  map f (Behavior b) = Behavior \e -> b (map (_ <<< f) e)

instance applyBehavior :: Apply Behavior where
  apply (Behavior f) (Behavior a) = Behavior \e -> a (f (compose <$> e))

instance applicativeBehavior :: Applicative Behavior where
  pure a = Behavior \e -> (_ $ a) <$> e
