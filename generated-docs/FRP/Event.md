## Module FRP.Event

#### `fix`

``` purescript
fix :: forall i o. (Event i -> { input :: Event i, output :: Event o }) -> Event o
```

Compute a fixed point

#### `fold`

``` purescript
fold :: forall a b. (a -> b -> b) -> Event a -> b -> Event b
```

Fold over values received from some `Event`, creating a new `Event`.

#### `sampleOn`

``` purescript
sampleOn :: forall a b. Event a -> Event (a -> b) -> Event b
```

Create an `Event` which samples the latest values from the first event
at the times when the second event fires.

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
Filterable Event
Apply Event
Applicative Event
Alt Event
Plus Event
Alternative Event
(Semigroup a) => Semigroup (Event a)
(Monoid a) => Monoid (Event a)
IsEvent Event
```

#### `never`

``` purescript
never :: forall a. Event a
```

#### `keepLatest`

``` purescript
keepLatest :: forall a. Event (Event a) -> Event a
```

Flatten a nested `Event`, reporting values only from the most recent
inner `Event`.

#### `subscribe`

``` purescript
subscribe :: forall eff a r. Event a -> (a -> Eff (frp :: FRP | eff) r) -> Eff (frp :: FRP | eff) (Eff (frp :: FRP | eff) Unit)
```

Subscribe to an `Event` by providing a callback.

`subscribe` returns a canceller function.


### Re-exported from Data.Filterable:

#### `Filterable`

``` purescript
class (Functor f) <= Filterable f  where
  filterMap :: forall a b. (a -> Maybe b) -> f a -> f b
```

`Filterable` represents data structures which can be _partitioned_/_filtered_.

- `partitionMap` - partition a data structure based on an either predicate.
- `partition` - partition a data structure based on boolean predicate.
- `filterMap` - map over a data structure and filter based on a maybe.
- `filter` - filter a data structure based on a boolean.

Laws:
- `map f ≡ filterMap (Just <<< f)`
- `filter ≡ filterMap <<< maybeBool`
- `filterMap p ≡ filter (isJust <<< p)`

Default implementations are provided by the following functions:

- `partitionDefault`
- `partitionDefaultFilter`
- `partitionDefaultFilterMap`
- `filterDefault`
- `filterDefaultPartition`
- `filterDefaultPartitionMap`

##### Instances
``` purescript
Filterable Array
Filterable Maybe
(Monoid m) => Filterable (Either m)
Filterable List
(Ord k) => Filterable (Map k)
```

### Re-exported from FRP.Event.Class:

#### `IsEvent`

``` purescript
class (Alternative event, Filterable event) <= IsEvent event  where
  fold :: forall a b. (a -> b -> b) -> event a -> b -> event b
  sampleOn :: forall a b. event a -> event (a -> b) -> event b
  fix :: forall i o. (event i -> { input :: event i, output :: event o }) -> event o
```

Functions which an `Event` type should implement, so that
`Behavior`s can be defined in terms of any such event type:

- `fold`: combines incoming values using the specified function,
starting with the specific initial value.
- `sampleOn`: samples an event at the times when a second event fires.
- `fix`: compute a fixed point, by feeding output events back in as
inputs.

#### `withLast`

``` purescript
withLast :: forall event a. IsEvent event => event a -> event { now :: a, last :: Maybe a }
```

Compute differences between successive event values.

#### `sampleOn_`

``` purescript
sampleOn_ :: forall event a b. IsEvent event => event a -> event b -> event a
```

Create an `Event` which samples the latest values from the first event
at the times when the second event fires, ignoring the values produced by
the second event.

#### `mapAccum`

``` purescript
mapAccum :: forall event a b c. IsEvent event => (a -> b -> Tuple b c) -> event a -> b -> event c
```

Map over an event with an accumulator.

For example, to keep the index of the current event:

```purescript
mapAccum (\x i -> Tuple (i + 1) (Tuple x i)) 0`.
```

#### `folded`

``` purescript
folded :: forall event a. IsEvent event => Monoid a => event a -> event a
```

Combine subsequent events using a `Monoid`.

#### `count`

``` purescript
count :: forall event a. IsEvent event => event a -> event Int
```

Count the number of events received.

