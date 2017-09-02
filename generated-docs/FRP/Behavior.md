## Module FRP.Behavior

#### `Behavior`

``` purescript
type Behavior = ABehavior Event
```

A `Behavior` acts like a continuous function of time.

We can construct a sample a `Behavior` from some `Event`, combine `Behavior`s
using `Applicative`, and sample a final `Behavior` on some other `Event`.

#### `ABehavior`

``` purescript
newtype ABehavior event a
```

`ABehavior` is the more general type of `Behavior`, which is parameterized
over some underlying `event` type.

Normally, you should use `Behavior` instead, but this type
can also be used with other types of events, including the ones in the
`Semantic` module.

##### Instances
``` purescript
(Functor event) => Functor (ABehavior event)
(Functor event) => Apply (ABehavior event)
(Functor event) => Applicative (ABehavior event)
(Functor event, Semigroup a) => Semigroup (ABehavior event a)
(Functor event, Monoid a) => Monoid (ABehavior event a)
```

#### `behavior`

``` purescript
behavior :: forall event a. (forall b. event (a -> b) -> event b) -> ABehavior event a
```

Construct a `Behavior` from its sampling function.

#### `step`

``` purescript
step :: forall event a. IsEvent event => a -> event a -> ABehavior event a
```

Create a `Behavior` which is updated when an `Event` fires, by providing
an initial value.

#### `sample`

``` purescript
sample :: forall event a b. ABehavior event a -> event (a -> b) -> event b
```

Sample a `Behavior` on some `Event`.

#### `sampleBy`

``` purescript
sampleBy :: forall event a b c. IsEvent event => (a -> b -> c) -> ABehavior event a -> event b -> event c
```

Sample a `Behavior` on some `Event` by providing a combining function.

#### `sample_`

``` purescript
sample_ :: forall event a b. IsEvent event => ABehavior event a -> event b -> event a
```

Sample a `Behavior` on some `Event`, discarding the event's values.

#### `unfold`

``` purescript
unfold :: forall event a b. IsEvent event => (a -> b -> b) -> event a -> b -> ABehavior event b
```

Create a `Behavior` which is updated when an `Event` fires, by providing
an initial value and a function to combine the current value with a new event
to create a new value.

#### `switcher`

``` purescript
switcher :: forall a. Behavior a -> Event (Behavior a) -> Behavior a
```

Switch `Behavior`s based on an `Event`.

#### `integral`

``` purescript
integral :: forall event a t. IsEvent event => Field t => Semiring a => (((a -> t) -> t) -> a) -> a -> ABehavior event t -> ABehavior event a -> ABehavior event a
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
integral' :: forall event t. IsEvent event => Field t => t -> ABehavior event t -> ABehavior event t -> ABehavior event t
```

Integrate with respect to some measure of time.

This function is a simpler version of `integral` where the function being
integrated takes values in the same field used to represent time.

#### `derivative`

``` purescript
derivative :: forall event a t. IsEvent event => Field t => Ring a => (((a -> t) -> t) -> a) -> ABehavior event t -> ABehavior event a -> ABehavior event a
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
derivative' :: forall event t. IsEvent event => Field t => ABehavior event t -> ABehavior event t -> ABehavior event t
```

Differentiate with respect to some measure of time.

This function is a simpler version of `derivative` where the function being
differentiated takes values in the same field used to represent time.

#### `solve`

``` purescript
solve :: forall t a. Field t => Semiring a => (((a -> t) -> t) -> a) -> a -> Behavior t -> (Behavior a -> Behavior a) -> Behavior a
```

Solve a first order differential equation of the form

```
da/dt = f a
```

by integrating once (specifying the initial conditions).

For example, the exponential function with growth rate `⍺`:

```purescript
exp = solve' 1.0 Time.seconds (⍺ * _)
```

#### `solve'`

``` purescript
solve' :: forall a. Field a => a -> Behavior a -> (Behavior a -> Behavior a) -> Behavior a
```

Solve a first order differential equation.

This function is a simpler version of `solve` where the function being
integrated takes values in the same field used to represent time.

#### `solve2`

``` purescript
solve2 :: forall t a. Field t => Semiring a => (((a -> t) -> t) -> a) -> a -> a -> Behavior t -> (Behavior a -> Behavior a -> Behavior a) -> Behavior a
```

Solve a second order differential equation of the form

```
d^2a/dt^2 = f a (da/dt)
```

by integrating twice (specifying the initial conditions).

For example, an (damped) oscillator:

```purescript
oscillate = solve2' 1.0 0.0 Time.seconds (\x dx -> -⍺ * x - δ * dx)
```

#### `solve2'`

``` purescript
solve2' :: forall a. Field a => a -> a -> Behavior a -> (Behavior a -> Behavior a -> Behavior a) -> Behavior a
```

Solve a second order differential equation.

This function is a simpler version of `solve2` where the function being
integrated takes values in the same field used to represent time.

#### `fixB`

``` purescript
fixB :: forall a. a -> (ABehavior Event a -> ABehavior Event a) -> ABehavior Event a
```

Compute a fixed point

#### `animate`

``` purescript
animate :: forall scene eff. ABehavior Event scene -> (scene -> Eff (frp :: FRP | eff) Unit) -> Eff (frp :: FRP | eff) (Eff (frp :: FRP | eff) Unit)
```

Animate a `Behavior` by providing a rendering function.


