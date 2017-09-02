## Module FRP.Event.Class

#### `IsEvent`

``` purescript
class (Alternative event) <= IsEvent event  where
  fold :: forall a b. (a -> b -> b) -> event a -> b -> event b
  mapMaybe :: forall a b. (a -> Maybe b) -> event a -> event b
  sampleOn :: forall a b. event a -> event (a -> b) -> event b
```

Functions which an `Event` type should implement, so that
`Behavior`s can be defined in terms of any such event type.

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


