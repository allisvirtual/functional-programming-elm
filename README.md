# functional-programming-elm

Exercise solutions and revision notes from a Functional Programming course in Elm.

## Layout

| Path | Contents |
|---|---|
| [`exercises/`](exercises) | One standalone Elm project per section (each with its own `elm.json` and `src/`) |
| [`notes/`](notes/README.md) | Revision notes per section, with type signatures and worked examples |

## Exercises

| Section | Topics | Modules |
|---|---|---|
| [A](exercises/A/src) | Pure functions, immutability, Elm syntax and types | `Caesar`, `Clock`, `Pythagoras` |
| [B](exercises/B/src) | Recursion, lists, `case`, `Maybe`, `map`/`filter`, `\|>` | `Caesar2`, `Pythagoras2`, `Extra` |
| [C](exercises/C/src) | Lambdas, `foldl`/`foldr`, point-free style, custom types | `Caesar3`, `CreditCard`, `Investments`, `Layouts`, `Shapes` |
| [D](exercises/D/src) | Expression trees, Huffman coding, generic binary trees | `Expressions`, `HuffmanTree`, `BinaryTree` |

## Running

The modules are libraries with no `main`; they're exercised from the REPL. Run everything
from inside a section folder:

```bash
cd exercises/A
```

```bash
elm repl
```

```elm
import Caesar exposing (..)
encode 3 'h'    -- 'k'
```
