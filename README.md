# purescript-behaviors

The goals of this library are to create a simple implementation of FRP which:

- Separates events and behaviors
- Can be used easily from JavaScript

Usually, libraries either:

- wrap existing JS libraries, which were designed with JS idioms in mind, but which are not necessarily a good match for PureScript, or
- implement new functionality in PureScript, and optionally expose a JavaScript API which is not a good match for JavaScript

I want to answer the question: is it possible to write a usable JavaScript library, which is tailored to take advantage of the abstraction capabilities of PureScript - functors, monads, monoids, etc.

The bulk of the code is implemented in JavaScript (`js/behavior.js`), with a thin wrapper written in PureScript.

## Building

```
npm install
grunt
```
