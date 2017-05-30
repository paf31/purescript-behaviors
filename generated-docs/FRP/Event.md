## Module FRP.Event

#### `Event`

``` purescript
data Event a
```

An `Event` represents a collection of discrete occurrences with associated
times. Conceptually, an `Event` is a (possibly-infinite) list of values-and-times:

```purescript
type Event a = List { value :: a, time :: Time }
```

Events are created from real events like timers or mouse clicks, and then
combined using the various functions and instances provided in this module.

Events are consumed by providing a callback using the `subscribe` function.

##### Instances
``` purescript
Functor Event
Apply Event
Applicative Event
Alt Event
Plus Event
Alternative Event
(Semigroup a) => Semigroup (Event a)
(Monoid a) => Monoid (Event a)
```

#### `never`

``` purescript
never :: forall a. Event a
```

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

#### `folded`

``` purescript
folded :: forall a. Monoid a => Event a -> Event a
```

Count the number of events received.

#### `withLast`

``` purescript
withLast :: forall a. Event a -> Event { now :: a, last :: Maybe a }
```

Compute differences between successive event values.

#### `filter`

``` purescript
filter :: forall a. (a -> Boolean) -> Event a -> Event a
```

Create an `Event` which only fires when a predicate holds.

#### `mapMaybe`

``` purescript
mapMaybe :: forall a b. (a -> Maybe b) -> Event a -> Event b
```

Filter out any `Nothing` events.

#### `sampleOn`

``` purescript
sampleOn :: forall a b. Event a -> Event (a -> b) -> Event b
```

Create an `Event` which samples the latest values from the first event
at the times when the second event fires.

#### `sampleOn_`

``` purescript
sampleOn_ :: forall a b. Event a -> Event b -> Event a
```

Create an `Event` which samples the latest values from the first event
at the times when the second event fires, ignoring the values produced by
the second event.

#### `subscribe`

``` purescript
subscribe :: forall eff a r. Event a -> (a -> Eff (frp :: FRP | eff) r) -> Eff (frp :: FRP | eff) Unit
```

Subscribe to an `Event` by providing a callback.

#### `create`

``` purescript
create :: forall eff a. Eff (frp :: FRP | eff) { event :: Event a, push :: a -> Eff (frp :: FRP | eff) Unit }
```

Create an event and a function which supplies a value to that event.


