module FRP.Event
  ( Event
  , zip
  , fold
  , filter
  , count
  , subscribe
  ) where

import Prelude

import Control.Monad.Eff (Eff)
import FRP (FRP)

foreign import data Event :: Type -> Type

foreign import pureImpl :: forall a. a -> Event a

foreign import mapImpl :: forall a b. (a -> b) -> Event a -> Event b

foreign import zip :: forall a b c. (a -> b -> c) -> Event a -> Event b -> Event c

foreign import mergeImpl :: forall a. Event a -> Event a -> Event a

instance functorEvent :: Functor Event where
  map = mapImpl

instance applyEvent :: Apply Event where
  apply = zip ($)

instance applicativeEvent :: Applicative Event where
  pure = pureImpl

instance semigroupEvent :: Semigroup (Event a) where
  append = mergeImpl

foreign import fold :: forall a b. (a -> b -> b) -> Event a -> b -> Event b

count :: forall a. Event a -> Event Int
count s = fold (\_ n -> n + 1) s 0

foreign import filter :: forall a. (a -> Boolean) -> Event a -> Event a

foreign import subscribe :: forall eff a r. (a -> Eff (frp :: FRP | eff) r) -> Event a -> Eff (frp :: FRP | eff) Unit
