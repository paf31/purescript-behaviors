## Module FRP.Event.Mouse

#### `move`

``` purescript
move :: Event { x :: Int, y :: Int }
```

Create an `Event` which fires when the mouse moves

#### `down`

``` purescript
down :: Event Int
```

Create an `Event` which fires when a mouse button is pressed

#### `up`

``` purescript
up :: Event Int
```

Create an `Event` which fires when a mouse button is released

#### `withPosition`

``` purescript
withPosition :: forall a. Event a -> Event { value :: a, pos :: Nullable { x :: Int, y :: Int } }
```

Create an event which also returns the current mouse position.

#### `withButtons`

``` purescript
withButtons :: forall a. Event a -> Event { value :: a, buttons :: Array Int }
```

Create an event which also returns the current mouse buttons.


