module FRP.Behavior
  ( Behavior()
  , step
  , sample
  , sample'
  , zip
  ) where

import FRP
import FRP.Event hiding (zip)

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

foreign import zip """
  function zip(f) {
    return function (b1) {
      return function (b2) {
        return Behavior.Behavior.zip(b1, b2, function(a, b) {
          return f(a)(b);  
        });
      };
    };
  }
  """ :: forall a b c. (a -> b -> c) -> Behavior a -> Behavior b -> Behavior c

instance functorBehavior :: Functor Behavior where
  (<$>) = mapImpl

instance applyBehavior :: Apply Behavior where
  (<*>) = zip ($)

instance applicativeBehavior :: Applicative Behavior where
  pure = pureImpl

foreign import step """
  function step(a) {
    return function (e) {
      return Behavior.Behavior.step(a, e);
    };
  }
  """ :: forall a. a -> Event a -> Behavior a

foreign import sample """
  function sample(f) {
    return function(b) {
      return function(e) {
        return Behavior.Behavior.sample(b, e, function(a, b) {
          return f(a)(b);
        });
      };
    };
  }
  """ :: forall a b c. (a -> b -> c) -> Behavior a -> Event b -> Event c

sample' :: forall a b. Behavior a -> Event b -> Event a
sample' = sample const
