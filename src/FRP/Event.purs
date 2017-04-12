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

-- | Create an `Event` which combines with the latest values from two other events.
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

-- | Fold over values received from some `Event`, creating a new `Event`.
foreign import fold :: forall a b. (a -> b -> b) -> Event a -> b -> Event b

-- | Count the number of events received.
count :: forall a. Event a -> Event Int
count s = fold (\_ n -> n + 1) s 0

-- | Create an `Event` which only fires when a predicate holds.
foreign import filter :: forall a. (a -> Boolean) -> Event a -> Event a

-- | Subscribe to an `Event` by providing a callback.
foreign import subscribe :: forall eff a r. (a -> Eff (frp :: FRP | eff) r) -> Event a -> Eff (frp :: FRP | eff) Unit
