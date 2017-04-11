## Module FRP.Event

#### `Event`

``` purescript
data Event :: Type -> Type
```

##### Instances
``` purescript
Functor Event
Apply Event
Applicative Event
Semigroup (Event a)
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


