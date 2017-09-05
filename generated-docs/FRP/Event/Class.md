## Module FRP.Event.Class

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

#### `mapAccum`

``` purescript
mapAccum :: forall event a b c. IsEvent event => (a -> b -> Tuple b c) -> event a -> b -> event c
```

Map over an event with an accumulator.

For example, to keep the index of the current event:

```purescript
mapAccum (\x i -> Tuple (i + 1) (Tuple x i)) 0`.
```

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

