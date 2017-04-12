## Module FRP.Event

#### `Event`

``` purescript
data Event :: Type -> Type
```

##### Instances
``` purescript
Functor Event
Apply Event
Applicative Event
Semigroup (Event a)
```

#### `zip`

``` purescript
zip :: forall a b c. (a -> b -> c) -> Event a -> Event b -> Event c
```

Create an `Event` which combines with the latest values from two other events.

#### `fold`

``` purescript
fold :: forall a b. (a -> b -> b) -> Event a -> b -> Event b
```

Fold over values received from some `Event`, creating a new `Event`.

#### `count`

``` purescript
count :: forall a. Event a -> Event Int
```

Count the number of events received.

#### `filter`

``` purescript
filter :: forall a. (a -> Boolean) -> Event a -> Event a
```

Create an `Event` which only fires when a predicate holds.

#### `subscribe`

``` purescript
subscribe :: forall eff a r. (a -> Eff (frp :: FRP | eff) r) -> Event a -> Eff (frp :: FRP | eff) Unit
```

Subscribe to an `Event` by providing a callback.


