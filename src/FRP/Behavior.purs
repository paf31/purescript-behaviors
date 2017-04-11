module FRP.Behavior
  ( Behavior()
  , step
  , sample
  , sample'
  , zip
  ) where

import Prelude
import FRP.Event (Event)

foreign import data Behavior :: Type -> Type

foreign import pureImpl :: forall a. a -> Behavior a

foreign import mapImpl :: forall a b. (a -> b) -> Behavior a -> Behavior b

foreign import zip :: forall a b c. (a -> b -> c) -> Behavior a -> Behavior b -> Behavior c

instance functorBehavior :: Functor Behavior where
  map = mapImpl

instance applyBehavior :: Apply Behavior where
  apply = zip ($)

instance applicativeBehavior :: Applicative Behavior where
  pure = pureImpl

foreign import step :: forall a. a -> Event a -> Behavior a

foreign import sample :: forall a b c. (a -> b -> c) -> Behavior a -> Event b -> Event c

sample' :: forall a b. Behavior a -> Event b -> Event a
sample' = sample const
