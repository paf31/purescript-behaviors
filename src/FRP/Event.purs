module FRP.Event
  ( Event()
  , subscribe
  ) where

import FRP

import Control.Monad.Eff

foreign import data Event :: * -> *

foreign import pureImpl """
  function pureImpl(a) {
    return Behavior.Event.pure(a);
  }
  """ :: forall a. a -> Event a

foreign import mapImpl """
  function mapImpl(f) {
    return function(e) {
      return Behavior.Event.map(e, f);
    };
  }
  """ :: forall a b. (a -> b) -> Event a -> Event b

foreign import applyImpl """
  function applyImpl(f) {
    return function (x) {
      return Behavior.Event.apply(f, x);
    };
  }
  """ :: forall a b. Event (a -> b) -> Event a -> Event b

instance functorEvent :: Functor Event where
  (<$>) = mapImpl

instance applyEvent :: Apply Event where
  (<*>) = applyImpl

instance applicativeEvent :: Applicative Event where
  pure = pureImpl

foreign import subscribe """
  function subscribe(f) {
    return function(e) {
      return function() {
        e.subscribe(function(a) {
          f(a)();
        });
      };
    };
  };
  """ :: forall eff a r. (a -> Eff (frp :: FRP | eff) r) -> Event a -> Eff (frp :: FRP | eff) Unit
 
