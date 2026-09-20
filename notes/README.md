# Functional Programming: revision notes (sections A, B, C)

| File | Section | Topics |
|---|---|---|
| [A-pure-functions-and-elm.md](A-pure-functions-and-elm.md) | A | Pure functions, immutability, Elm basics, types, syntax, operators, `Basics`/`Char`/`String`/`Tuple` |
| [B-recursion-lists-maybe.md](B-recursion-lists-maybe.md) | B | Recursion, lists, `case`, `Maybe`, strings vs lists, `map` & `filter`, `\|>`, `List` reference |
| [C-lambdas-folds-custom-types.md](C-lambdas-folds-custom-types.md) | C | Lambdas, `foldl`/`foldr`, `partition`, point-free style, custom types |

## Things that trip people up

- `'a'` (Char) vs `"a"` (String). `++` only joins Strings/Lists.
- Function application binds tighter than every operator:
  `String.cons first (normalize rest)` needs the brackets.
- `f x :: rest` is `(f x) :: rest`, not `f (x :: rest)`.
- Patterns cannot call functions, so `case String.uncons s of` evaluates *before* matching.
- `\( a, b ) -> ...` is one tuple parameter; `\a b -> ...` is two parameters.
- In folds the lambda is `\element acc -> ...`, element first; position, not the names,
  decides which is which.
- `(a -> Bool) -> List a -> List a`: without the brackets it means three parameters.
- `->` in types groups to the **right**; function application groups to the **left**.
- `//` truncates towards zero (`-7 // 2 == -3`), `floor` rounds down (`floor -3.9 == -4`).
- `modBy` is always non-negative for a positive divisor; `remainderBy` keeps the sign.
- Elm has no `Int.toString` or `Char.toString`; it's `String.fromInt` / `String.fromChar`.
- Module name must match the filename, capitalised, no dashes.
