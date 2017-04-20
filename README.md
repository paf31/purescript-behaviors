# purescript-behaviors

An implementation of FRP which separates discrete values ("events") from
continuous values ("behaviors").

- [Example](test/Main.purs)
- [API Documentation](generated-docs/FRP)

## Building

```
pulp build
npm run example
```

## Notes

This library defines two type constructors:

- `Event`, which models discrete events like mouse clicks and key presses, and
- `Behavior`, which models continuous functions of time, like the current time or the mouse position.

The `FRP.Event.*` and `FRP.Behavior.*` modules provide several ways to construct
events and behaviors, and these can be further combined by using the type class
instances and functions which are provided.

Ultimately, we are interested in sampling events, which can be done using the `subscribe` function.
However, behaviors can provide a more useful model for certain problems, since they are defined
at every time, and support different operations such as integration and differentiation. A behavior
must be sampled on some event in order to be useful, but the choice of sampling interval is delayed
until as late as possible, which allows us to treat behaviors like actual functions of time.
