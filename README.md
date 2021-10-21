# debug-show

This package can convert (almost) any PureScript value to a String, without
requiring a Show instance, i.e. the type signature is

```purescript
debugShow :: forall a. a -> String
```

without any constraints.

## Why?

Because `Show` instances increase code size.

## How it works

It does this by inspecting the runtime representation of values. Unline plain
`JSON.stringify`, it recognizes the PureScript data constructor name.. Unline
plain `JSON.stringify`, it recognizes the PureScript data constructor of a
value and shows its name in the output. It also has special handling for various other types whose runtime representation is unreadable (currently: `Data.Map` which is a 2-3 tree underneath).

Unline the typeclass-based approach, `debug-show` has serious limits on the customizability of the output. In particular, you can't change the output of `debugShow` on a value by wrapping it in a newtype, becuase the runtime representation is the same.
In the future we'll add an ability to register decoders for custom data constructors (similar to how `Data.Map` is handled).

## Output format

Currently it is ugly, because it's based on `JSON.stringify`. On the other hand it is machine readable, and can be prettified using standard tools.

Sum types are represented using an array where the first element is the tag name, and the rest are the arguments.
In particular enums are ugly, because they are shown using an one-element array.
