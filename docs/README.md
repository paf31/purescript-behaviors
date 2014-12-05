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

    step :: forall a. a -> Event a -> Behavior a


## Module FRP.Event

### Types

    data Event :: * -> *


### Type Class Instances

    instance applicativeEvent :: Applicative Event

    instance applyEvent :: Apply Event

    instance functorEvent :: Functor Event


### Values

    subscribe :: forall eff a r. (a -> Eff (frp :: FRP | eff) r) -> Event a -> Eff (frp :: FRP | eff) Unit


## Module FRP.Event.Time

### Values

    interval :: Number -> Event Number