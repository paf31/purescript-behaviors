## Module FRP.Event.Keyboard

#### `down`

``` purescript
down :: Event Int
```

Create an `Event` which fires when a key is pressed

#### `up`

``` purescript
up :: Event Int
```

Create an `Event` which fires when a key is released

#### `withKeys`

``` purescript
withKeys :: forall a. Event a -> Event { value :: a, keys :: Array Int }
```

Create an event which also returns the current pressed keycodes.


