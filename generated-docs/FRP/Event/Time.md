## Module FRP.Event.Time

#### `interval`

``` purescript
interval :: Int -> Event Int
```

Create an event which fires every specified number of milliseconds.

#### `withTime`

``` purescript
withTime :: forall a. Event a -> Event { value :: a, time :: Int }
```

Create an event which reports the current time in milliseconds since the epoch.


