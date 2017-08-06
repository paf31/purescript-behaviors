## Module FRP.Behavior

#### `Behavior`

``` purescript
newtype Behavior event a
```

A `Behavior` acts like a continuous function of time.

We can construct a sample a `Behavior` from some `Event`, combine `Behavior`s
using `Applicative`, and sample a final `Behavior` on some other `Event`.

##### Instances
``` purescript
(Functor event) => Functor (Behavior event)
(Functor event) => Apply (Behavior event)
(Functor event) => Applicative (Behavior event)
(Functor event, Semigroup a) => Semigroup (Behavior event a)
(Functor event, Monoid a) => Monoid (Behavior event a)
```

#### `behavior`

``` purescript
behavior :: forall event a. (forall b. event (a -> b) -> event b) -> Behavior event a
```

Construct a `Behavior` from its sampling function.

#### `step`

``` purescript
step :: forall event a. IsEvent event => a -> event a -> Behavior event a
```

Create a `Behavior` which is updated when an `Event` fires, by providing
an initial value.

#### `sample`

``` purescript
sample :: forall event a b. Behavior event a -> event (a -> b) -> event b
```

Sample a `Behavior` on some `Event`.

#### `sampleBy`

``` purescript
sampleBy :: forall event a b c. IsEvent event => (a -> b -> c) -> Behavior event a -> event b -> event c
```

Sample a `Behavior` on some `Event` by providing a combining function.

#### `sample_`

``` purescript
sample_ :: forall event a b. IsEvent event => Behavior event a -> event b -> event a
```

Sample a `Behavior` on some `Event`, discarding the event's values.

#### `unfold`

``` purescript
unfold :: forall event a b. IsEvent event => (a -> b -> b) -> event a -> b -> Behavior event b
```

Create a `Behavior` which is updated when an `Event` fires, by providing
an initial value and a function to combine the current value with a new event
to create a new value.

#### `integral`

``` purescript
integral :: forall event a t. IsEvent event => Field t => Semiring a => (((a -> t) -> t) -> a) -> a -> Behavior event t -> Behavior event a -> Behavior event a
```

Integrate with respect to some measure of time.

This function approximates the integral using the trapezium rule at the
implicit sampling interval.

The `Semiring` `a` should be a vector field over the field `t`. To represent
this, the user should provide a _grate_ which lifts a multiplication
function on `t` to a function on `a`. Simple examples where `t ~ a` can use
the `integral'` function instead.

#### `integral'`

``` purescript
integral' :: forall event t. IsEvent event => Field t => t -> Behavior event t -> Behavior event t -> Behavior event t
```

Integrate with respect to some measure of time.

This function is a simpler version of `integral` where the function being
integrated takes values in the same field used to represent time.

#### `derivative`

``` purescript
derivative :: forall event a t. IsEvent event => Field t => Ring a => (((a -> t) -> t) -> a) -> Behavior event t -> Behavior event a -> Behavior event a
```

Differentiate with respect to some measure of time.

This function approximates the derivative using a quotient of differences at the
implicit sampling interval.

The `Semiring` `a` should be a vector field over the field `t`. To represent
this, the user should provide a grate which lifts a division
function on `t` to a function on `a`. Simple examples where `t ~ a` can use
the `derivative'` function.

#### `derivative'`

``` purescript
derivative' :: forall event t. IsEvent event => Field t => Behavior event t -> Behavior event t -> Behavior event t
```

Differentiate with respect to some measure of time.

This function is a simpler version of `derivative` where the function being
differentiated takes values in the same field used to represent time.

#### `fixB`

``` purescript
fixB :: forall a. a -> (Behavior Event a -> Behavior Event a) -> Behavior Event a
```

Compute a fixed point

#### `animate`

``` purescript
animate :: forall scene eff. Behavior Event scene -> (scene -> Eff (frp :: FRP | eff) Unit) -> Eff (frp :: FRP | eff) Unit
```

Animate a `Behavior` by providing a rendering function.


