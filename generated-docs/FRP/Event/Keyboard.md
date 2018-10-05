## Module FRP.Event.Keyboard

#### `Keyboard`

``` purescript
newtype Keyboard
```

A handle for creating events from the keyboard.

#### `getKeyboard`

``` purescript
getKeyboard :: Effect Keyboard
```

Get a handle for working with the keyboard.

#### `disposeKeyboard`

``` purescript
disposeKeyboard :: Keyboard -> Effect Unit
```

#### `down`

``` purescript
down :: Event String
```

Create an `Event` which fires when a key is pressed

#### `up`

``` purescript
up :: Event String
```

Create an `Event` which fires when a key is released

#### `withKeys`

``` purescript
withKeys :: forall a. Keyboard -> Event a -> Event { value :: a, keys :: Set String }
```

Create an event which also returns the currently pressed keys.


