## Module FRP.Behavior

#### `Behavior`

``` purescript
data Behavior :: * -> *
```

##### Instances
``` purescript
instance functorBehavior :: Functor Behavior
instance applyBehavior :: Apply Behavior
instance applicativeBehavior :: Applicative Behavior
```

#### `zip`

``` purescript
zip :: forall a b c. (a -> b -> c) -> Behavior a -> Behavior b -> Behavior c
```

#### `step`

``` purescript
step :: forall a. a -> Event a -> Behavior a
```

#### `sample`

``` purescript
sample :: forall a b c. (a -> b -> c) -> Behavior a -> Event b -> Event c
```

#### `sample'`

``` purescript
sample' :: forall a b. Behavior a -> Event b -> Event a
```


