module FRP.Event
  ( Event()
  , zip
  , fold
  , filter
  , count
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

foreign import zip """
  function zip(f) {
    return function (e1) {
      return function (e2) {
        return Behavior.Event.zip(e1, e2, function(a, b) {
          return f(a)(b);  
        });
      };
    };
  }
  """ :: forall a b c. (a -> b -> c) -> Event a -> Event b -> Event c

foreign import mergeImpl """
  function mergeImpl(e1) {
    return function(e2) {
      return Behavior.Event.merge(e1, e2);
    };
  }
  """ :: forall a. Event a -> Event a -> Event a

instance functorEvent :: Functor Event where
  (<$>) = mapImpl

instance applyEvent :: Apply Event where
  (<*>) = zip ($)

instance applicativeEvent :: Applicative Event where
  pure = pureImpl

instance semigroupEvent :: Semigroup (Event a) where
  (<>) = mergeImpl

foreign import fold """
  function fold(f) {
    return function(e) {
      return function(b) {
        return Behavior.Event.fold(e, b, function(a, b) {
          return f(a)(b); 
        });
      };
    };
  }
  """ :: forall a b. (a -> b -> b) -> Event a -> b -> Event b

count :: forall a. Event a -> Event Number
count s = fold (\_ n -> n + 1) s 0

foreign import filter """
  function filter(p) {
    return function(e) {
      return Behavior.Event.filter(e, p);
    };
  }
  """ :: forall a. (a -> Boolean) -> Event a -> Event a

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
 
