## Module FRP.Event.Mouse

#### `Mouse`

``` purescript
newtype Mouse
```

A handle for creating events from the mouse position and buttons.

#### `getMouse`

``` purescript
getMouse :: Effect Mouse
```

Get a handle for working with the mouse.

#### `disposeMouse`

``` purescript
disposeMouse :: Mouse -> Effect Unit
```

#### `move`

``` purescript
move :: Mouse -> Event { x :: Int, y :: Int }
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
withPosition :: forall a. Mouse -> Event a -> Event { value :: a, pos :: Maybe { x :: Int, y :: Int } }
```

Create an event which also returns the current mouse position.

#### `withButtons`

``` purescript
withButtons :: forall a. Mouse -> Event a -> Event { value :: a, buttons :: Set Int }
```

Create an event which also returns the current mouse buttons.


