module FRP.Behavior
  ( Behavior()
  , step
  ) where

import FRP
import FRP.Event

import Control.Monad.Eff

foreign import data Behavior :: * -> *

foreign import pureImpl """
  function pureImpl(a) {
    return Behavior.Behavior.pure(a);
  }
  """ :: forall a. a -> Behavior a

foreign import mapImpl """
  function mapImpl(f) {
    return function(e) {
      return Behavior.Behavior.map(e, f);
    };
  }
  """ :: forall a b. (a -> b) -> Behavior a -> Behavior b

foreign import applyImpl """
  function applyImpl(f) {
    return function (x) {
      return Behavior.Behavior.apply(f, x);
    };
  }
  """ :: forall a b. Behavior (a -> b) -> Behavior a -> Behavior b

instance functorBehavior :: Functor Behavior where
  (<$>) = mapImpl

instance applyBehavior :: Apply Behavior where
  (<*>) = applyImpl

instance applicativeBehavior :: Applicative Behavior where
  pure = pureImpl

foreign import step """
  function step(a) {
    return function (e) {
      return Behavior.Behavior.step(a, e);
    };
  }
  """ :: forall a. a -> Event a -> Behavior a

