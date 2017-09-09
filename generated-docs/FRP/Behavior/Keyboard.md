## Module FRP.Behavior.Keyboard

#### `keys`

``` purescript
keys :: Behavior (Set Int)
```

A `Behavior` which reports the keys which are currently pressed.

#### `key`

``` purescript
key :: Int -> Behavior Boolean
```

A `Behavior` which reports whether a specific key is currently pressed.


