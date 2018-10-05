## Module FRP.Behavior.Mouse

#### `position`

``` purescript
position :: Mouse -> Behavior (Maybe { x :: Int, y :: Int })
```

A `Behavior` which reports the current mouse position, if it is known.

#### `buttons`

``` purescript
buttons :: Mouse -> Behavior (Set Int)
```

A `Behavior` which reports the mouse buttons which are currently pressed.


