## Module FRP.Behavior.Keyboard

#### `keys`

``` purescript
keys :: Keyboard -> Behavior (Set String)
```

A `Behavior` which reports the keys which are currently pressed.

#### `key`

``` purescript
key :: Keyboard -> String -> Behavior Boolean
```

A `Behavior` which reports whether a specific key is currently pressed.


