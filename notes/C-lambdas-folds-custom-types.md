# Section C: Anonymous functions / Fold functions / Custom types I

Slides 24–33

---

## 1. Anonymous functions (lambdas)

A function written **on the spot, without a name**. The `\` is meant to look like the Greek
letter λ (lambda). Read `\x -> x ^ 2` as "take `x`, give back `x` squared".

| Expression | Type | Example | Result |
|---|---|---|---|
| `\x -> x + 1` | `number -> number` | `(\x -> x + 1) 5` | `6` |
| `\x y -> x + y` | `number -> number -> number` | `(\x y -> x + y) 2 3` | `5` |
| `\( a, b ) -> a + b` | `( number, number ) -> number` | `(\( a, b ) -> a + b) ( 2, 3 )` | `5` |

```elm
cube x = x ^ 3
List.map cube [3,4,5,6]                == [27,64,125,216]   -- named function
List.map (\x -> x ^ 2) [3,4,5,6]       == [9,16,25,36]      -- lambda

List.filter (\x -> String.length x < 4) ["stroopwafel","ja","nee","fiets"]
                                       == ["ja","nee"]
```

Use a lambda when the function is a one-off, or when it needs extra information from the
surrounding scope (a key, a search list, …). A named helper is equally correct; it's a
readability choice, not a correctness one.

### How many parameters?

The **caller** decides how many arguments it passes:

| Caller | Passes | Lambda shape |
|---|---|---|
| `List.map` | 1 (the element) | `\x -> ...` |
| `List.filter` | 1 (the element) | `\x -> ...` |
| `List.foldl` / `List.foldr` | 2 (element, accumulator) | `\x acc -> ...` |

Give `foldl` a 1-parameter lambda and you get a `TYPE MISMATCH`.
On its own a lambda can take any number: `(\x y z -> x + y + z) 1 2 3 == 6`.

### One parameter that is a tuple ≠ two parameters

```elm
\( a, b ) -> ...     -- ONE parameter, a pair, destructured on the spot
\a b -> ...          -- TWO separate parameters
```

The brackets and comma are the giveaway.

```elm
List.filter (\( a, b ) -> a > b) [(1,2),(5,3)]   == [(5,3)]
List.map (\n -> ( n, n * n )) (List.range 1 4)   == [(1,1),(2,4),(3,9),(4,16)]
```

### Parameter names carry no meaning

Only **position** matters. These are identical:

```elm
List.foldl (\digit acc -> digit :: acc) [] [1,2,3,4]     == [4,3,2,1]
List.foldl (\banana kiwi -> banana :: kiwi) [] [1,2,3,4] == [4,3,2,1]
```

But position does matter:

```elm
List.foldl (\x acc -> acc - x) 0 [1,2,3]   == -6
List.foldl (\x acc -> x - acc) 0 [1,2,3]   == 2
```

Convention: name the accumulator `acc` and keep it second, so the names match reality.

## 2. Fold functions

A fold walks a list while carrying a **running result** (the **accumulator**, `acc`).
It is the functional replacement for a loop with a running total. You describe **one step**;
the fold does the walking.

| Function | Type | Example | Result |
|---|---|---|---|
| `List.foldl` | `(a -> b -> b) -> b -> List a -> b` | `List.foldl (\x acc -> x + acc) 0 [2,5,7,4]` | `18` |
| `List.foldr` | `(a -> b -> b) -> b -> List a -> b` | `List.foldr (\x acc -> x + acc) 0 [2,5,7,4]` | `18` |

```
List.foldl  (\x acc -> x + acc)  0   [2,5,7,4]
            ^ 1. update rule     ^2.  ^3. the list
                                 starting value
```

- **`a`** = the type of the list's **elements**
- **`b`** = the type of the **running result** (the start value, the accumulator, and the
  final answer are all `b`)
- The update rule **receives** a `b` and **returns** a `b`, which is why it's `a -> b -> b`.
- The lambda always gets **element first, accumulator second**.

### `foldl`: starts from the left

```elm
List.foldl (\x acc -> x + acc) 0 [2,5,7,4]   == 18
```

| Step | element | acc before | acc after |
|---|---|---|---|
| start | | | 0 |
| 1 | 2 | 0 | 2 |
| 2 | 5 | 2 | 7 |
| 3 | 7 | 7 | 14 |
| 4 | 4 | 14 | 18 |

In general: `List.foldl (\x acc -> x ⊕ acc) init [2,5,7,4]` = `4 ⊕ (7 ⊕ (5 ⊕ (2 ⊕ init)))`

### `foldr`: starts from the right

`List.foldr (\x acc -> x ⊕ acc) init [2,5,7,4]` = `2 ⊕ (5 ⊕ (7 ⊕ (4 ⊕ init)))`

```
[2,5,7,4] with (+) and init 0:
   4 + 0  = 4
   7 + 4  = 11
   5 + 11 = 16
   2 + 16 = 18
```

With an empty list the fold never calls the update rule, so the answer is the start value.

### Examples (slides 28–30)

```elm
List.foldr (\x acc -> x + acc) 0 [2,5,7,4]   == 18
List.foldr (+) 0 [2,5,7,4]                   == 18     -- operators work as functions
List.foldl (+) 0 [2,5,7,4]                   == 18

List.foldr (\x acc -> x :: acc) [] [2,5,7,4] == [2,5,7,4]   -- rebuilds the list
List.foldr (::) [] [2,5,7,4]                 == [2,5,7,4]
List.foldl (::) [] [2,5,7,4]                 == [4,7,5,2]   -- REVERSES it

List.foldr (\x acc -> x ^ 2 :: acc) [] [2,5,7,4]                == [4,25,49,16]  -- a map
List.foldr (\x acc -> if x > 4 then x :: acc else acc) [] [2,5,7,4] == [5,7]     -- a filter
```

`foldl` + `::` reverses because `::` always adds to the **front**, so each new element jumps
ahead of everything gathered so far:

| Visiting | acc before | `x :: acc` | acc after |
|---|---|---|---|
| 1 | `[]` | `1 :: []` | `[1]` |
| 2 | `[1]` | `2 :: [1]` | `[2,1]` |
| 3 | `[2,1]` | `3 :: [2,1]` | `[3,2,1]` |
| 4 | `[3,2,1]` | `4 :: [3,2,1]` | `[4,3,2,1]` |

Change only where the element is placed and the reversal disappears:

```elm
List.foldl (\x acc -> acc ++ [x]) [] [1,2,3,4]   == [1,2,3,4]
```

### When `a` and `b` are different types

```elm
addLength : String -> Int -> Int
addLength word total =
    String.length word + total

List.foldl addLength 0 ["ja","nee","fiets"]   == 10      -- total goes 0 → 2 → 5 → 10
-- a = String, b = Int
-- List.foldl : (String -> Int -> Int) -> Int -> List String -> Int
```

### `foldr` **is** list recursion

```elm
-- the recursive case of a list recursion:
"/" ++ String.fromInt first ++ layout rest
-- the same thing written as a foldr step:
\num str -> "/" ++ String.fromInt num ++ str
```

- the `init` value = your `[] ->` branch
- `acc` = the result the fold already computed for `rest`

Any recursion of the form "base value for `[]`, combine `first` with the result for `rest`"
can be rewritten as a `foldr`. Elm's own definition of `foldl` is just list recursion:

```elm
foldl func acc list =
    case list of
        [] ->
            acc

        x :: xs ->
            foldl func (func x acc) xs
```

### `List.partition`: filter that keeps both halves

| Function | Type | Example | Result |
|---|---|---|---|
| `List.partition` | `(a -> Bool) -> List a -> ( List a, List a )` | `List.partition (\x -> x > 2) [1,2,3,4]` | `([3,4],[1,2])` |

The first list holds the elements where the test was `True`, the second the rest.

### `List.range` (handy with folds and maps)

| Function | Type | Example | Result |
|---|---|---|---|
| `List.range` | `Int -> Int -> List Int` | `List.range 1 5` | `[1,2,3,4,5]` |

## 3. Point-free style / partial application with folds

`List.foldl` wants three arguments. Give it two and you get back a function waiting for the
list:

```
List.foldl                    : (Int -> String -> String) -> String -> List Int -> String
List.foldl accLeft            :                              String -> List Int -> String
List.foldl accLeft initLeft   :                                        List Int -> String
```

Each argument supplied chops one arrow off the front, so these two definitions are the
**same function**:

```elm
layout lst = List.foldl accLeft initLeft lst   -- the list is named, then passed on
layout     = List.foldl accLeft initLeft       -- the list is never named (point-free)
```

You can (and should) still write the type annotation above it:

```elm
layout : List Int -> String
layout =
    List.foldl accLeft initLeft
```

And the accumulator's start value is not a function, just a constant:

```elm
initLeft : String
initLeft =
    "/"
```

**Direction decides which side the new piece goes on.** With the same start value `"/"`:

```
foldl, \num str -> str ++ String.fromInt num ++ "/"
   "/"  →  "/" ++ "1/"  →  "/1/" ++ "3/"  →  "/1/3/" ++ "5/"  =  "/1/3/5/"

foldr, \num str -> "/" ++ String.fromInt num ++ str
   "/"  →  "/5" ++ "/"  →  "/3" ++ "/5/"  →  "/1" ++ "/3/5/"  =  "/1/3/5/"
```

Put it on the wrong side and you get `"/5/3/1/"`.

## 4. Custom types

Define your own type with a list of **variants**, separated by `|`.

```elm
type SpecialCharacter
    = ACharacter Char
    | ACode Int
```

- The **type name** is capitalised: `SpecialCharacter`.
- Each variant may carry zero or more values.
- **Variants are constructors, i.e. functions:**

```elm
ACharacter : Char -> SpecialCharacter        ACharacter 'a' : SpecialCharacter
ACode      : Int  -> SpecialCharacter        ACode 150      : SpecialCharacter
```

- A variant carrying nothing is a plain value, not a function:

```elm
type Colour = Blue | Green | Red | Yellow
Blue : Colour
```

- Because constructors are functions, partial application works on them:
  `List.map ACode [1,2,3]` builds a list of three `SpecialCharacter`s.

### Pattern matching on a custom type

```elm
getCode : SpecialCharacter -> Int
getCode special =
    case special of
        ACharacter character ->
            Char.toCode character

        ACode code ->
            code

-- getCode (ACharacter 'a') == 97
-- getCode (ACode 150)      == 150
```

One branch per variant; each branch **names the data** that variant carries. Use `_` when
you only care which variant it is:

```elm
isEuros : Money -> Bool
isEuros money =
    case money of
        Euros _ ->
            True

        Dollars _ ->
            False
```

The compiler knows exactly how many variants exist, so leaving one out gives
`MISSING PATTERNS`.

### A worked example

```elm
type Money
    = Euros Float
    | Dollars Float

dollar2euroRate : Float
dollar2euroRate =
    0.86

toEuros : Money -> Float
toEuros m =
    case m of
        Euros e ->
            e

        Dollars d ->
            d * dollar2euroRate

-- toEuros (Euros 10)   == 10
-- toEuros (Dollars 10) == 8.6
```

### Parameterized (generic) types

```elm
type Maybe a
    = Nothing
    | Just a
```

`Maybe` is an **ordinary custom type** with no compiler magic; you could write it yourself:

```elm
type MyMaybe a
    = MyNothing
    | MyJust a
```

Its only privilege is being imported automatically.

- `a` is a **type parameter**, not a type name (type names are always capitalised, so you
  never write `type a = ...`).
- `Maybe` on its own is **not a type**; it's a recipe. Fill in the blank to get a type:

| You write | Values it allows |
|---|---|
| `Maybe Int` | `Nothing`, `Just 5` |
| `Maybe String` | `Nothing`, `Just "hi"` |
| `Maybe Money` | `Nothing`, `Just (Euros 5)` |

`List` works the same way: `List Int` is a type, `List` alone is not.

Payoff: you write the type and its functions **once** and they work for every element type,
exactly like `myMap : (a -> b) -> List a -> List b`.

### Exposing a custom type

```elm
module Investments exposing (Money(..), split)
```

`Money(..)` exports the type **and** its variants, so other modules can write `Euros 5`.
Without `(..)` they'd know the type exists but couldn't build a value.
In the REPL use `import Investments exposing (..)`.

## 5. Quick reference

```elm
\x -> ...                 \x y -> ...          \( a, b ) -> ...

List.foldl     : (a -> b -> b) -> b -> List a -> b       -- left to right
List.foldr     : (a -> b -> b) -> b -> List a -> b       -- right to left
List.partition : (a -> Bool) -> List a -> ( List a, List a )
List.range     : Int -> Int -> List Int

type Name = VariantA | VariantB Int | VariantC Float Float
module M exposing (Name(..), f)
```

| Want to… | Use |
|---|---|
| change every element | `List.map` / `foldr` with `::` |
| keep some elements | `List.filter` / `foldr` with an `if` |
| keep both groups | `List.partition` |
| reduce a list to one value | `List.foldl` / `List.foldr` |
| reverse a list | `List.foldl (::) []` |
| a one-off function argument | a lambda |
| your own kind of value | a custom type + `case` |
