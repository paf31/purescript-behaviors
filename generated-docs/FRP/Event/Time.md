## Module FRP.Event.Time

#### `interval`

``` purescript
interval :: Int -> Event Int
```

Create an event which fires every specified number of milliseconds.

#### `animationFrame`

``` purescript
animationFrame :: Event Unit
```

Create an event which fires every frame (using `requestAnimationFrame`).

#### `withTime`

``` purescript
withTime :: forall a. Event a -> Event { value :: a, time :: Number }
```

Create an event which reports the current time in milliseconds since the epoch.


