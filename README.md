# purescript-behaviors

- [Example](test/Main.purs)
- [API Documentation](generated-docs/FRP)
- [Try `purescript-behaviors` in the browser](http://try.purescript.org/?backend=behaviors)

![Example](screenshots/1.gif)

## Building

```
pulp build
npm run example
```

## Introduction

Push-pull FRP is concerned with _events_ and _behaviors_. Events are
values which occur discretely over time, and behaviors act like continuous
functions of time.

Why bother with behaviors at all, when the machines we work with deal with events
such as interrupts at the most basic level?

Well, we can work with continuous functions of time in a variety of ways, including by
differentiation and integration. Also, working with a conceptually infinitely-dense
representation means that we can defer the choice of sampling interval until we are
ready to render our results.

This library takes a slightly novel approach by constructing behaviors from events.

```purescript
newtype ABehavior event a = ABehavior (forall b. event (a -> b) -> event b)

type Behavior = ABehavior Event
```

Here, a `Behavior` is constructed directly from its sampling function.
The various functions which work with this representation can delay the choice of
sampling interval for as long as possible, but ultimately this `Behavior` is
equivalent to working with events directly, albeit with alternative, function-like
instances.

This representation has the correct type class instances, and supports operations such
as integration, differentiation and even recursion, which means we can use it to solve
interactive differential equations. For example, here is an exponential function
computed as the solution of a differential equation:

```purescript
exp = fixB 1.0 \b -> integrate 1.0 time ((-2.0 * _) <$> b)
```

See the [example project](test/Main.purs) for a more interesting, interactive example.
