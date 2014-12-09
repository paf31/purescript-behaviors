# Module Documentation

## Module FRP

### Types

    data FRP :: !


## Module FRP.Behavior

### Types

    data Behavior :: * -> *


### Type Class Instances

    instance applicativeBehavior :: Applicative Behavior

    instance applyBehavior :: Apply Behavior

    instance functorBehavior :: Functor Behavior


### Values

    sample :: forall a b c. (a -> b -> c) -> Behavior a -> Event b -> Event c

    sample' :: forall a b. Behavior a -> Event b -> Event a

    step :: forall a. a -> Event a -> Behavior a

    zip :: forall a b c. (a -> b -> c) -> Behavior a -> Behavior b -> Behavior c


## Module FRP.Event

### Types

    data Event :: * -> *


### Type Class Instances

    instance applicativeEvent :: Applicative Event

    instance applyEvent :: Apply Event

    instance functorEvent :: Functor Event

    instance semigroupEvent :: Semigroup (Event a)


### Values

    count :: forall a. Event a -> Event Number

    filter :: forall a. (a -> Boolean) -> Event a -> Event a

    fold :: forall a b. (a -> b -> b) -> Event a -> b -> Event b

    subscribe :: forall eff a r. (a -> Eff (frp :: FRP | eff) r) -> Event a -> Eff (frp :: FRP | eff) Unit

    zip :: forall a b c. (a -> b -> c) -> Event a -> Event b -> Event c


## Module FRP.Event.Time

### Values

    interval :: Number -> Event Number