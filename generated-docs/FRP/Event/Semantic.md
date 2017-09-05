## Module FRP.Event.Semantic

## Denotational Semantics

The goal here is to define a meaning function from `Behavior`s to some semantic
domain in such a way that type class instances pull back from the instances on the
semantic domain, in the sense of
[_type class morphisms_](http://conal.net/papers/type-class-morphisms/).

The implementation of a `Behavior` is polymorphic in the choice of underlying
`Event`. The meaning function is specified with respect to the `Semantic`
event type provided in this module.

We consider behaviors which are valid sampling functions. Precisely, a
`Behavior (Semantic time) a`, which is a function of type

```purescript
b :: forall b. Semantic time (a -> b) -> Semantic time b
```

should preserve the set of input times in the output:

```purescript
map fst (unwrap (b e)) = map fst (unwrap e) :: List time
```

The semantic domain for these behaviors is just the function type

```purescript
time -> a
```

The meaning of the sampling function `b` is then the function

```purescript
\t -> valueOf (sample b (once t id))
```

where

```purescript
valueOf (Semantic (Tuple _ a : Nil)) = a
once t a = Semantic (Tuple t a : Nil)
```

Note that the time-preservation property ensures that the result of
applying `b` is an event consisting of a single time point at time `t`,
so this is indeed a well-defined function.

In addition, we have this property, due to time-preservation:

```
sample b (once t f) = once t (valueOf (sample b (once t f)))
```

### Instances

#### `Functor`

`map` of the meaning is the meaning of `map`:

```
map f (meaning b)
= f <<< meaning b
= \t -> f (valueOf (sample b (once t id)))
  {- parametricity -}
= \t -> valueOf (sample b (map (_ <<< f) (once t id)))
= meaning (map f b)
```

#### `Apply`

`<*>` of the meanings is the meaning of `<*>`:

```
meaning (a <*> b)
= \t -> valueOf (sample (a <*> b) (once t id))
= \t -> valueOf (sample b (sample a (compose <$> once t id)))
= \t -> valueOf (sample b (sample a (once t id)))
= \t -> valueOf (sample b (sample a (once t id)))
  {- sampling preserves times -}
= \t -> valueOf (sample b (once t (valueOf (sample a (once t id))))
= \t -> valueOf (sample b (once t (meaning a t)))
  {- parametricity -}
= \t -> meaning a t (valueOf (sample b (once t id)))
= \t -> meaning a t (meaning b t)
= meaning a <*> meaning b
```

#### `Applicative`

The meaning of `pure` is `pure`:

```
meaning (pure a)
= \t -> valueOf (sample (pure a) (once t id))
= \t -> a
= pure a
```

#### `Semantic`

``` purescript
newtype Semantic time a
  = Semantic (List (Tuple time a))
```

The semantic domain for events

##### Instances
``` purescript
Newtype (Semantic time a) _
Functor (Semantic time)
(Ord time) => Apply (Semantic time)
(Bounded time) => Applicative (Semantic time)
(Ord time) => Alt (Semantic time)
(Ord time) => Plus (Semantic time)
(Bounded time) => Alternative (Semantic time)
(Ord time, Semigroup a) => Semigroup (Semantic time a)
(Bounded time, Monoid a) => Monoid (Semantic time a)
Filterable (Semantic time)
(Bounded time) => IsEvent (Semantic time)
```


