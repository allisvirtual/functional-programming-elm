# Section A: Introduction / Pure functions / Elm

Slides 7–14

---

## 1. What functional programming is

- Imperative programming describes **how** (step by step: loops, assignments, state).
- Functional programming describes **what** (expressions and functions that compute a result).
- Everything is an **expression** that evaluates to a value. There are no statements.

**Why FP:** clean code that's easy to read and reason about, easy to test, popular, fun,
stimulates creative thinking, good for maths, parallel/distributed programming and GUIs.

### Two big differences from imperative code

| Imperative | Functional |
|---|---|
| `for` / `while` loops | **recursion** and **list operations** |
| variables change value | **immutable** values only |

```c
int i = 7;        // imperative
i++;              // changes i, a side effect
```
```elm
newI = i + 1      -- functional: i is untouched, a NEW name is bound
```

## 2. Pure functions

A function is **pure** when:

1. The result depends **only** on its arguments (same input → same output, always).
2. It has **no side effects** (changes nothing outside itself: no globals, no I/O, no mutation).

```c
double get_pi() { i++; return 3.14; }   // NOT pure: it modifies i
```

Pure functions are why you can test a function by just calling it, and why order of
evaluation doesn't matter.

## 3. Immutability

Nothing ever changes value. Operations build **new** values.

- \+ simpler programs: no state management, no temporal coupling
- \+ parallel programming is easy (thread-safe by construction)
- \+ no side effects
- \- efficiency? Still high, thanks to internal **structural sharing** (new values reuse
  the unchanged parts of old ones instead of copying).

## 4. Elm

- Pure functional language, 2012, made for web apps, **compiles to JavaScript**.
- No runtime exceptions, friendly compiler errors, easy to test, reusable code.
- **Case-sensitive.** Lowercase = values and functions. Uppercase = types and constructors
  (e.g. `True`, `False`, `Just`).

### Tooling

```bash
elm repl                                 # interactive; ":exit" to leave
elm make src/Caesar.elm --output=elm.js  # compile / type-check
elm reactor                              # serve project at localhost:8000
```

- In the REPL: `import Caesar exposing (..)` then call functions.
- `Success! Compiled 1 module` = your code is valid. A `NO MAIN` message afterwards is
  **not an error:** it just means the module has no `main` to draw a page from.
- Trust `elm make`. Editor squiggles can be stale (restart the Elm language server after
  adding files/folders).

## 5. Modules

```elm
module Caesar exposing (encode, decode)   -- export only these
module Caesar exposing (..)               -- export everything
```

- The module name **must match the filename** (`Caesar.elm` → `module Caesar`).
- Names must start with a capital and contain only letters/digits, so **no dashes**.
- Anything not in `exposing (...)` is private to the file (and invisible in the REPL).
- Import another module: `import Pythagoras exposing (..)`.
- `elm/core` modules `Basics`, `Char`, `String`, `List`, `Maybe`, `Tuple` need **no import**.

### Comments

```elm
-- single line
{- block
   comment -}
```

## 6. Types

### Basic types
`Int`, `Float`, `Bool`, `Char`, `String`

```elm
42          -- Int
3.14        -- Float
True        -- Bool
'a'         -- Char   (single quotes, exactly one character)
"a"         -- String (double quotes, any length)
```

`'a'` and `"a"` are **different types**. `++` works on `String`, not `Char`.

### Collections

```elm
myList  : List Int
myList  = [ 2, 5, 7, 11 ]              -- all elements the same type

myTuple : ( Int, List Char )
myTuple = ( 35, [ 'a', 'b', 'c' ] )    -- fixed length, mixed types allowed

myRecord : { name : String, age : Int }
myRecord = { name = "Jan", age = 42 }
```

- **List:** any length, one element type. `[True, "Hello"]` is a type error.
- **Tuple:** fixed length, types may differ. `(1,2)`, `(1,"Hello")`, `(1,2,3)`, `(1,(2,3))`
  and `((1,2),3)` all have **different** types.
- Also: **records** and **custom types** (section C).

### Type annotations

```elm
isTriple : Int -> Int -> Int -> Bool
--          arg1   arg2   arg3   return
```

**The last type is always the return value**; everything before it is an argument, in order.

```elm
sqr        : Int -> Int                        -- 1 arg
encode     : Int -> Char -> Char               -- 2 args
pythTriple : ( Int, Int ) -> ( Int, Int, Int ) -- 1 arg (a tuple!) → a tuple
```

`( Int, Int ) -> ...` is **one tuple argument**, not two `Int` arguments.

### Type variables (polymorphism)

A **lowercase** name in a type means "any type, the same one everywhere this letter appears".

```elm
List.length : List a -> Int          -- works on a list of anything
List.length [1, 2, 3]            == 3
List.length ["Hello", "world"]   == 2
List.length [[1,2], [1,2,3], []] == 3   -- a list of lists; inner lengths irrelevant
```

A type containing type variables is called **polymorphic**.
Special ones: `number` (Int or Float), `comparable` (numbers, Char, String, and
tuples/lists of those).

Functions are values too, so they can live in a list:

```elm
List.length [ String.toUpper, String.toLower, String.reverse ]   == 3
```

### Currying (preview, full treatment in D)

Every Elm function really takes **one** argument:

```elm
isTriple : Int -> Int -> Int -> Bool
--   is   : Int -> (Int -> (Int -> Bool))
```

So supplying fewer arguments gives back a function (**partial application**):
`isTriple 9 : Int -> Int -> Bool`.

## 7. Function syntax

```elm
rental : Int -> Int -> Int
rental x y =
    20 * x * y + 300
```

Name, parameters separated by spaces, `=`, then the body. No `return`, no braces:
the body **is** the result.

### Arguments can be destructured in the head

```elm
farmRental : ( Int, Int ) -> Int
farmRental ( h, w ) =
    h * w
```

### `if ... then ... else`

```elm
farmRental : ( Int, Int ) -> Int
farmRental ( h, w ) =
    if h * w > 200 then
        h * w + 2 * (h + w)

    else if h * w < 100 then
        2 * (h + w)

    else
        h * w

-- farmRental ( 10, 30 ) == 380
```

- `else` is **mandatory**: an `if` is an expression and must always produce a value.
- Both branches must have the **same type**.
- There is no `else <cond> then`; it's `else if <cond> then`.

### `let ... in`: local names

```elm
shiftChar : Int -> Char -> Char -> Char
shiftChar key base c =
    let
        baseCode =
            Char.toCode base

        shifted =
            modBy 26 (Char.toCode c - baseCode + key)
    in
    Char.fromCode (shifted + baseCode)

-- shiftChar 5 'a' 'x' == 'c'
```

- Bindings between `let` and `in` are local and invisible outside.
- A later binding may use an earlier one.
- The expression **after `in`** is the function's result.

### Multiple return values → use a tuple

```elm
areaPeriCalc : Int -> Int -> ( Int, Int )
areaPeriCalc h w =
    ( h * w, 2 * (h + w) )

-- areaPeriCalc 10 30 == ( 300, 80 )

farmRental2 : ( Int, Int ) -> Int
farmRental2 ( h, w ) =
    let
        ( ar, pe ) =
            areaPeriCalc h w        -- destructure inside a let
    in
    ar + pe

-- farmRental2 ( 10, 30 ) == 380
```

## 8. Operators

| Operator | Type | Example | Result |
|---|---|---|---|
| `+` `-` `*` | `number -> number -> number` | `6 * 11 - 2` | `64` |
| `/` | `Float -> Float -> Float` | `7 / 2` | `3.5` |
| `//` | `Int -> Int -> Int` (drops the remainder) | `7 // 2`<br>`-7 // 2` | `3`<br>`-3` |
| `^` | `number -> number -> number` | `2 ^ 10`<br>`2 ^ 0.5` | `1024`<br>`1.414…` |
| `==` | `a -> a -> Bool` | `1 == 1` | `True` |
| `/=` | `a -> a -> Bool` | `1 /= 2` | `True` |
| `<` `>` `<=` `>=` | `comparable -> comparable -> Bool` | `3 < 5` | `True` |
| `&&` | `Bool -> Bool -> Bool` | `True && False` | `False` |
| `\|\|` | `Bool -> Bool -> Bool` | `True \|\| False` | `True` |
| `++` | `appendable -> appendable -> appendable` | `"Hello" ++ " " ++ "world"`<br>`[1,2] ++ [3]` | `"Hello world"`<br>`[1,2,3]` |

**Precedence:** function application binds tightest, then `^`, then `* / //`, then `+ -`,
then comparisons, then `&&`, then `||`.

```elm
6 * 11 - 2                      == 64
6 * (11 - 2)                    == 54       -- parentheses direct the computation
not True && False               -- = (not True) && False = False
"/" ++ String.fromInt 5 ++ "/"  -- = "/" ++ (String.fromInt 5) ++ "/" = "/5/"
```

Any binary operator can be used in **prefix** form by wrapping it in parentheses.
Arguments are separated by spaces, not commas.

```elm
(+) 2 2             == 4
(-) ((*) 6 11) 2    == 64      -- same as 6 * 11 - 2
```

Elm never converts types for you: `"/" ++ 1` is an error, so write `"/" ++ String.fromInt 1`.

## 9. Library functions

### `Basics`: always in scope, no prefix needed

| Function | Type | Example | Result |
|---|---|---|---|
| `modBy` | `Int -> Int -> Int` | `modBy 3 10`<br>`modBy 26 -1` | `1`<br>`25` (**always non-negative** for a positive divisor) |
| `remainderBy` | `Int -> Int -> Int` | `remainderBy 3 -10` | `-1` (keeps the sign) |
| `abs` | `number -> number` | `abs -17` | `17` |
| `negate` | `number -> number` | `negate 5` | `-5` |
| `max` | `comparable -> comparable -> comparable` | `max 3 7` | `7` |
| `min` | `comparable -> comparable -> comparable` | `min 3 7` | `3` |
| `clamp` | `comparable -> comparable -> comparable -> comparable` | `clamp 0 10 42` | `10` (low, high, value) |
| `sqrt` | `Float -> Float` | `sqrt 16` | `4` |
| `pi` | `Float` (a value, not a function) | `pi` | `3.141592653589793` |
| `toFloat` | `Int -> Float` | `toFloat 3` | `3` (as a `Float`) |
| `round` | `Float -> Int` | `round 3.6`<br>`round 3.4` | `4`<br>`3` |
| `floor` | `Float -> Int` | `floor 3.9`<br>`floor -3.9` | `3`<br>`-4` (rounds **down**) |
| `ceiling` | `Float -> Int` | `ceiling 3.1` | `4` |
| `truncate` | `Float -> Int` | `truncate -3.9` | `-3` (chops **towards zero**) |
| `not` | `Bool -> Bool` | `not True` | `False` |
| `xor` | `Bool -> Bool -> Bool` | `xor True False` | `True` |
| `identity` | `a -> a` | `identity 5` | `5` |
| `always` | `a -> b -> a` | `always 5 99` | `5` (ignores the second argument) |

### `Char`

| Function | Type | Example | Result |
|---|---|---|---|
| `Char.toCode` | `Char -> Int` | `Char.toCode 'a'`<br>`Char.toCode 'A'` | `97`<br>`65` |
| `Char.fromCode` | `Int -> Char` | `Char.fromCode 97` | `'a'` |
| `Char.isLower` | `Char -> Bool` | `Char.isLower 'a'` | `True` |
| `Char.isUpper` | `Char -> Bool` | `Char.isUpper 'a'` | `False` |
| `Char.isAlpha` | `Char -> Bool` | `Char.isAlpha '7'` | `False` (`a-z`, `A-Z` only) |
| `Char.isDigit` | `Char -> Bool` | `Char.isDigit '7'` | `True` (`'0'`–`'9'`) |
| `Char.isAlphaNum` | `Char -> Bool` | `Char.isAlphaNum '7'` | `True` (letter **or** digit) |
| `Char.isHexDigit` | `Char -> Bool` | `Char.isHexDigit 'f'` | `True` |
| `Char.isOctDigit` | `Char -> Bool` | `Char.isOctDigit '9'` | `False` (`'0'`–`'7'`) |
| `Char.toUpper` | `Char -> Char` | `Char.toUpper 'a'` | `'A'` |
| `Char.toLower` | `Char -> Char` | `Char.toLower 'A'` | `'a'` |

ASCII ranges worth remembering: `'0'`–`'9'` = 48–57, `'A'`–`'Z'` = 65–90, `'a'`–`'z'` = 97–122.
Because digits are consecutive, `Char.toCode c - Char.toCode '0'` turns `'7'` into `7`.

### `String`

| Function | Type | Example | Result |
|---|---|---|---|
| `String.length` | `String -> Int` | `String.length "Hello"` | `5` |
| `String.isEmpty` | `String -> Bool` | `String.isEmpty ""` | `True` |
| `String.toUpper` | `String -> String` | `String.toUpper "wORLd"` | `"WORLD"` |
| `String.toLower` | `String -> String` | `String.toLower "wORLd"` | `"world"` |
| `String.reverse` | `String -> String` | `String.reverse "Hello"` | `"olleH"` |
| `String.words` | `String -> List String` | `String.words "Hello in the world"` | `["Hello","in","the","world"]` |
| `String.append` | `String -> String -> String` | `String.append "ab" "cd"` | `"abcd"` (same as `++`) |
| `String.fromInt` | `Int -> String` | `String.fromInt 42` | `"42"` |
| `String.fromFloat` | `Float -> String` | `String.fromFloat 3.5` | `"3.5"` |
| `String.fromChar` | `Char -> String` | `String.fromChar 'a'` | `"a"` |

There is **no** `Int.toString` and **no** `Char.toString` in Elm 0.19; conversions *into* a
String live in the `String` module and are named `String.fromX`. (Old tutorials show a
general `toString`; it was removed.)

### `List` / `Tuple` (more in section B)

| Function | Type | Example | Result |
|---|---|---|---|
| `List.head` | `List a -> Maybe a` | `List.head [42, 73]`<br>`List.head []` | `Just 42`<br>`Nothing` |
| `List.length` | `List a -> Int` | `List.length [1,2,3]` | `3` |
| `Tuple.first` | `( a, b ) -> a` | `Tuple.first (1,"Hello")` | `1` (**pairs only**) |
| `Tuple.second` | `( a, b ) -> b` | `Tuple.second (1,"Hello")` | `"Hello"` |

`Tuple.first (1,2,3)` is a type error: a 3-tuple is not a pair.

## 10. Reading errors

Every Elm expression has a type, and the REPL prints it:

```
> True
True : Bool
> "Hello"
"Hello" : String
> [ 'H', 'e', 'l', 'l', 'o' ]
['H','e','l','l','o'] : List Char
> not
<function> : Bool -> Bool
```

So `not "Hello"` is a **type error**: `not` expects a `Bool` and got a `String`.
Type errors mean something is semantically wrong. Making them on purpose is good practice:
they're how the compiler explains your program back to you.

## 11. Habits the course keeps rewarding

- **No code duplication.** When similar lines appear, make a helper function.
- **Small functions, combined.** Build bigger functions out of the ones you already wrote
  instead of one big monolithic function.
- Give every top-level function a **type annotation**.
- Test in `elm repl` as you go.
