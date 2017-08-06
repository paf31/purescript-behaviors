-- | ## Denotational Semantics
-- |
-- | (a work in progress)
-- |
-- | The goal here is to define a meaning function from `Behavior`s to some semantic
-- | domain in such a way that type class instances pull back from the instances on the
-- | semantic domain, in the sense of
-- | [_type class morphisms_](http://conal.net/papers/type-class-morphisms/).
-- |
-- | The implementation of a `Behavior` is polymorphic in the choice of underlying
-- | `Event`. The meaning function is specified with respect to the `Semantic`
-- | event type provided in this module.
-- |
-- | We consider behaviors which are valid sampling functions. Precisely, a
-- | `Behavior (Semantic time) a`, which is a function of type
-- |
-- | ```purescript
-- | b :: forall b. Semantic time (a -> b) -> Semantic time b
-- | ```
-- |
-- | should preserve the set of input times in the output:
-- |
-- | ```purescript
-- | map fst (unwrap (b e)) = map fst (unwrap e) :: List time
-- | ```
-- |
-- | The semantic domain for these behaviors is just the function type
-- |
-- | ```purescript
-- | time -> a
-- | ```
-- |
-- | The meaning of the sampling function `b` is then the function
-- |
-- | ```purescript
-- | \t -> valueOf (b (Semantic (singleton t id)))
-- | ```
-- |
-- | where
-- |
-- | ```purescript
-- | valueOf (Semantic (Tuple _ a : Nil)) = a
-- | ```
-- |
-- | Note that the time-preservation property ensures that the result of
-- | applying `b` is an event consisting of a single time point at time `t`,
-- | so this is indeed a well-defined function.
-- |
-- | _TODO_: check the instances and functions match the semantics

module FRP.Event.Semantic
  ( Semantic(..)
  ) where

import Prelude

import Control.Alt (class Alt)
import Control.Alternative (class Alternative, class Plus)
import Control.Apply (lift2)
import Data.List ((:))
import Data.List as List
import Data.Maybe (Maybe)
import Data.Monoid (class Monoid, mempty)
import Data.Newtype (class Newtype)
import Data.Traversable (mapAccumL, traverse)
import Data.Tuple (Tuple(..), fst)
import FRP.Event (class IsEvent)

-- | The semantic domain for events
newtype Semantic time a = Semantic (List.List (Tuple time a))

derive instance newtypeSemantic :: Newtype (Semantic time a) _

derive instance functorSemantic :: Functor (Semantic time)

merge
  :: forall time a
   . Ord time
  => List.List (Tuple time a)
  -> List.List (Tuple time a)
  -> List.List (Tuple time a)
merge xs       List.Nil = xs
merge List.Nil ys       = ys
merge xs@(Tuple tx x : xs') ys@(Tuple ty y : ys')
  | tx <= ty  = Tuple tx x : merge xs' ys
  | otherwise = Tuple ty y : merge xs ys'

latestAt
  :: forall time a
   . Ord time
  => time
  -> List.List (Tuple time a)
  -> Maybe (Tuple time a)
latestAt t xs = List.last (List.takeWhile ((_ <= t) <<< fst) xs)

instance applySemantic :: Ord time => Apply (Semantic time) where
  apply (Semantic xs) (Semantic ys) =
      Semantic (List.mapMaybe fx xs `merge` List.mapMaybe fy ys)
    where
      fx (Tuple t f) = map f <$> latestAt t ys
      fy (Tuple t a) = map (_ $ a) <$> latestAt t xs

instance applicativeSemantic :: Bounded time => Applicative (Semantic time) where
  pure a = Semantic (List.singleton (Tuple bottom a))

instance altSemantic :: Ord time => Alt (Semantic time) where
  alt (Semantic xs1) (Semantic ys1) = Semantic (merge xs1 ys1)

instance plusSemantic :: Ord time => Plus (Semantic time) where
  empty = Semantic List.Nil

instance alternativeSemantic :: Bounded time => Alternative (Semantic time)

instance semigroupSemantic :: (Ord time, Semigroup a) => Semigroup (Semantic time a) where
  append = lift2 append

instance monoidSemantic :: (Bounded time, Monoid a) => Monoid (Semantic time a) where
  mempty = pure mempty

instance semanticIsEvent :: Bounded time => IsEvent (Semantic time) where
  fold :: forall a b. (a -> b -> b) -> Semantic time a -> b -> Semantic time b
  fold f (Semantic xs) b0 = Semantic ((mapAccumL step b0 xs).value) where
    step b (Tuple t a) =
      let b' = f a b
      in { accum: b'
         , value: Tuple t b'
         }

  sampleOn :: forall a b. Semantic time a -> Semantic time (a -> b) -> Semantic time b
  sampleOn (Semantic xs) (Semantic ys) = Semantic (List.mapMaybe go ys) where
    go (Tuple t f) = map f <$> latestAt t xs

  mapMaybe :: forall a b. (a -> Maybe b) -> Semantic time a -> Semantic time b
  mapMaybe f (Semantic xs) = Semantic (List.mapMaybe (traverse f) xs)
