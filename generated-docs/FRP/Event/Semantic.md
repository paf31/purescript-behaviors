## Module FRP.Event.Semantic

## Denotational Semantics

(a work in progress)

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
\t -> valueOf (b (Semantic (singleton t id)))
```

where

```purescript
valueOf (Semantic (Tuple _ a : Nil)) = a
```

Note that the time-preservation property ensures that the result of
applying `b` is an event consisting of a single time point at time `t`,
so this is indeed a well-defined function.

_TODO_: check the instances and functions match the semantics

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
(Bounded time) => IsEvent (Semantic time)
```


