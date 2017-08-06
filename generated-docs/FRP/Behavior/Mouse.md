## Module FRP.Behavior.Mouse

#### `position`

``` purescript
position :: Behavior Event (Maybe { x :: Int, y :: Int })
```

A `Behavior` which reports the current mouse position, if it is known.

#### `buttons`

``` purescript
buttons :: Behavior Event (Set Int)
```

A `Behavior` which reports the mouse buttons which are currently pressed.


