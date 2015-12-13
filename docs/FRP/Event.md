## Module FRP.Event

#### `Event`

``` purescript
data Event :: * -> *
```

##### Instances
``` purescript
instance functorEvent :: Functor Event
instance applyEvent :: Apply Event
instance applicativeEvent :: Applicative Event
instance semigroupEvent :: Semigroup (Event a)
```

#### `zip`

``` purescript
zip :: forall a b c. (a -> b -> c) -> Event a -> Event b -> Event c
```

#### `fold`

``` purescript
fold :: forall a b. (a -> b -> b) -> Event a -> b -> Event b
```

#### `count`

``` purescript
count :: forall a. Event a -> Event Int
```

#### `filter`

``` purescript
filter :: forall a. (a -> Boolean) -> Event a -> Event a
```

#### `subscribe`

``` purescript
subscribe :: forall eff a r. (a -> Eff (frp :: FRP | eff) r) -> Event a -> Eff (frp :: FRP | eff) Unit
```


