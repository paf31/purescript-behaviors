## Module FRP.Behavior

#### `Behavior`

``` purescript
newtype Behavior a
```

A `Behavior` acts like a continuous function of time.

We can construct a sample a `Behavior` from some `Event`, combine `Behavior`s
using `Applicative`, and sample a final `Behavior` on some other `Event`.

##### Instances
``` purescript
Functor Behavior
Apply Behavior
Applicative Behavior
```

#### `step`

``` purescript
step :: forall a. a -> Event a -> Behavior a
```

Create a `Behavior` which is updated when an `Event` fires, by providing
an initial value.

#### `sample`

``` purescript
sample :: forall a b c. (a -> b -> c) -> Behavior a -> Event b -> Event c
```

Sample a `Behavior` on some `Event`.

#### `sample'`

``` purescript
sample' :: forall a b. Behavior a -> Event b -> Event a
```

Sample a `Behavior` on some `Event`, discarding the event's payload.


