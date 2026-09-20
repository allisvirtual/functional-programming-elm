# Section B: Recursion / List & Maybe / Map & Filter

Slides 15–23

---

## 1. Loops vs recursion

Elm has **no `for` and no `while`**. Repetition is done by a function calling itself.

A recursive function always has two parts:

1. **Base case:** the smallest input, answered directly (stops the recursion).
2. **Recursive case:** handle one piece, then call yourself on a **smaller** input.

```elm
factorial : Int -> Int
factorial n =
    if n <= 1 then
        1                        -- base case

    else
        n * factorial (n - 1)    -- recursion

-- factorial 5 == 120
```

Because `n! = (n-1)! * n` for `n >= 1`.

> Every recursion must move towards its base case, or it loops forever
> (`RangeError: Maximum call stack size exceeded`). Press `Ctrl+C` in the REPL.

## 2. Lists

```elm
[ 1, 2, 3 ]        -- List Int
[]                 -- the empty list
1 :: [ 2, 3 ]      -- "cons": put an element on the FRONT → [1,2,3]
[ 1 ] ++ [ 2, 3 ]  -- join two lists  → [1,2,3]
```

| Operator | Type | Example | Result |
|---|---|---|---|
| `::` | `a -> List a -> List a` | `1 :: [2,3]` | `[1,2,3]` |
| `++` | `List a -> List a -> List a` | `[1,2] ++ [3]` | `[1,2,3]` |

- All elements must have the **same type**. `[ 1, 'a' ]` is a type error.
- Lists are **immutable**: operations build new lists.
- **Every list is built from `::` and `[]`:**
  `[1,2,3]` is shorthand for `1 :: 2 :: 3 :: []`.
  This is exactly the shape recursion takes apart.
- `::` and `[]` are **syntax**, not `List` library functions, so you can still use them
  when the `List` library is off limits.

## 3. Pattern matching with `case ... of`

```elm
sum : List Int -> Int
sum list =
    case list of
        [] ->
            0

        x :: xs ->
            x + sum xs

-- sum [3, 4, 42, 73] == 122
-- = 3 + (4 + (42 + (73 + 0)))
```

### Patterns you can write

| Pattern | Matches | Example binding |
|---|---|---|
| `[]` | the empty list | n/a |
| `first :: rest` | at least one element | for `[1,2,3]`: `first = 1`, `rest = [2,3]` |
| `[ x ]` | exactly one element | for `[9]`: `x = 9` |
| `first :: second :: rest` | at least two elements | for `[8,7,6]`: `8`, `7`, `[6]` |
| `_` | anything (value not needed) | n/a |
| `_ :: rest` | skips the first element | for `[1,2,3]`: `rest = [2,3]` |
| `( a, b ) :: rest` | a list of pairs (patterns nest) | for `[(1,2),(3,4)]`: `a = 1`, `b = 2` |

```elm
sumPairs : List ( Int, Int ) -> List Int
sumPairs pairs =
    case pairs of
        [] ->
            []

        ( a, b ) :: rest ->
            (a + b) :: sumPairs rest

-- sumPairs [(1,2),(3,4)] == [3,7]
```

### Matching two things at once: put them in a tuple

```elm
equal : List Int -> List Int -> Bool
equal listA listB =
    case ( listA, listB ) of
        ( [], [] ) ->
            True

        ( x :: xs, [] ) ->
            False

        ( [], y :: ys ) ->
            False

        ( x :: xs, y :: ys ) ->
            x == y && equal xs ys

-- equal [1,2] [1,2] == True
```

### Rules

- **Exhaustiveness:** the compiler forces you to cover every shape. Forget `[]` or `Nothing`
  and you get `MISSING PATTERNS`, a free safety net.
- Branches are tried **top to bottom**; the first matching one wins.
- **Patterns describe a shape: they cannot call functions.** `case String.uncons s of`
  runs `uncons` once, *before* matching; the pattern then describes its result.

### `case` vs `if / else`

| `if / else` | `case ... of` |
|---|---|
| branches on a `Bool` | branches on the **shape** of any value |
| can't extract data | **destructures** while matching (gives you `first` and `rest`) |
| no exhaustiveness check | compiler checks all cases are covered |

```elm
if List.isEmpty lst then ... else ...   -- a boolean test
case lst of [] -> ... ; x :: xs -> ...  -- a test AND it hands you x and xs
```

Rule of thumb: use `case` when branching on the shape of a list, `Maybe` or custom type;
use `if` for a plain boolean test.

## 4. The three recursion patterns

**(a) Transform every element:** the "map" shape

```elm
doubleAll : List Int -> List Int
doubleAll xs =
    case xs of
        [] ->
            []

        x :: rest ->
            2 * x :: doubleAll rest

-- doubleAll [1,2,3] == [2,4,6]
```

**(b) Keep some elements:** the "filter" shape

```elm
keepEven : List Int -> List Int
keepEven xs =
    case xs of
        [] ->
            []

        x :: rest ->
            if modBy 2 x == 0 then
                x :: keepEven rest      -- keep

            else
                keepEven rest           -- drop

-- keepEven [1,2,3,4] == [2,4]
```

**(c) Recurse on a number instead of a list**

```elm
countdown : Int -> List Int
countdown n =
    if n <= 0 then
        []

    else
        n :: countdown (n - 1)

-- countdown 3 == [3,2,1]
```

Both arguments may change in a recursive call, e.g. `f (n - 1) (start + 1)`.

> **Precedence trap:** function application binds tighter than any operator, so
> `2 * x :: doubleAll rest` means `(2 * x) :: (doubleAll rest)` which is correct.
> But `String.cons first keepLetters rest` is **wrong**: it passes `String.cons` three
> arguments. Write `String.cons first (keepLetters rest)`.

## 5. `Maybe`: a value that might be missing

Elm has **no `null`**. When a function can't always answer, the type says so:

```elm
type Maybe a
    = Just a      -- "here is the answer"
    | Nothing     -- "there is no answer"
```

It is an ordinary custom type, not magic. Its two constructors:

```elm
Nothing : Maybe a
Just    : a -> Maybe a
```

Functions that return one:

```elm
List.head [2,3,4]   == Just 2
List.head []        == Nothing
List.minimum []     == Nothing
String.uncons ""    == Nothing
String.toInt "4a"   == Nothing
```

Get the value out with `case`:

```elm
describe : Maybe Int -> String
describe m =
    case m of
        Nothing ->
            "nothing there"

        Just n ->
            "got " ++ String.fromInt n

-- describe (Just 7) == "got 7"
-- describe Nothing  == "nothing there"
```

Because the type says `Maybe`, the compiler **forces** you to handle the missing case.
You can never use a `Maybe Float` as if it were a `Float`.

### `Maybe` helpers

| Function | Type | Example | Result |
|---|---|---|---|
| `Maybe.withDefault` | `a -> Maybe a -> a` | `Maybe.withDefault 0 (List.head [7,8])`<br>`Maybe.withDefault 0 (List.head [])` | `7`<br>`0` |
| `Maybe.map` | `(a -> b) -> Maybe a -> Maybe b` | `Maybe.map (\x -> x + 1) (Just 4)`<br>`Maybe.map (\x -> x + 1) Nothing` | `Just 5`<br>`Nothing` |
| `Maybe.andThen` | `(a -> Maybe b) -> Maybe a -> Maybe b` | `Maybe.andThen List.head (Just [1,2])`<br>`Maybe.andThen List.head (Just [])` | `Just 1`<br>`Nothing` |

`Maybe.map` transforms the value **if it's there**; `andThen` chains a step that may itself fail.

### A recursive function can return a `Maybe`

```elm
lastElement : List a -> Maybe a
lastElement xs =
    case xs of
        [] ->
            Nothing

        [ x ] ->
            Just x

        _ :: rest ->
            lastElement rest

-- lastElement [1,2,3] == Just 3
-- lastElement []      == Nothing
```

When the recursive call returns a `Maybe`, you usually have to `case` on that result and
combine it with the current element.

### List vs Maybe: the same idea, different words

| Type | "nothing there" | "something there" |
|---|---|---|
| `List` | `[]` | `first :: rest` |
| `Maybe` | `Nothing` | `Just x` |

## 6. Strings are not lists

`String` is its own type, so you **cannot** `case` on it with `::`. Two approaches.

**Option A: one character at a time**

| Function | Type | Example | Result |
|---|---|---|---|
| `String.uncons` | `String -> Maybe ( Char, String )` | `String.uncons "Hello"`<br>`String.uncons ""` | `Just ('H',"ello")`<br>`Nothing` |
| `String.cons` | `Char -> String -> String` | `String.cons 'H' "ello"` | `"Hello"` |

```elm
countVowels : String -> Int
countVowels s =
    case String.uncons s of
        Nothing ->
            0

        Just ( c, rest ) ->
            if List.member c [ 'a','e','i','o','u' ] then
                1 + countVowels rest

            else
                countVowels rest

-- countVowels "Hello world" == 3
```

Note: you write `Nothing ->`, not `"" ->`, because you are matching on `uncons`'s **answer**
(a `Maybe`), not on the string itself. (`case str of "" -> ...` is legal but gives you no way
to reach the first character and the rest.)

**Option B: convert to a list and back**

| Function | Type | Example | Result |
|---|---|---|---|
| `String.toList` | `String -> List Char` | `String.toList "abc"` | `['a','b','c']` |
| `String.fromList` | `List Char -> String` | `String.fromList ['a','b','c']` | `"abc"` |

```elm
shout : String -> String
shout s =
    s
        |> String.toList
        |> List.map Char.toUpper
        |> String.fromList

-- shout "abc" == "ABC"
```

### Other `String` functions

| Function | Type | Example | Result |
|---|---|---|---|
| `String.map` | `(Char -> Char) -> String -> String` | `String.map Char.toUpper "abc"` | `"ABC"` |
| `String.filter` | `(Char -> Bool) -> String -> String` | `String.filter Char.isDigit "a1b2"` | `"12"` |
| `String.contains` | `String -> String -> Bool` | `String.contains "amp" "Example"` | `True` |
| `String.startsWith` | `String -> String -> Bool` | `String.startsWith "the" "theory"` | `True` |
| `String.endsWith` | `String -> String -> Bool` | `String.endsWith "ry" "theory"` | `True` |
| `String.indexes` | `String -> String -> List Int` | `String.indexes "a" "banana"` | `[1,3,5]` |
| `String.toInt` | `String -> Maybe Int` | `String.toInt "42"`<br>`String.toInt "4a"` | `Just 42`<br>`Nothing` |
| `String.toFloat` | `String -> Maybe Float` | `String.toFloat "3.5"` | `Just 3.5` |

(Plus everything from section A: `length`, `isEmpty`, `reverse`, `toUpper`, `toLower`,
`words`, `append`, `fromInt`, `fromFloat`, `fromChar`.)

### Strings ↔ Lists cheat sheet

| Strings | Lists |
|---|---|
| `case String.uncons str of` | `case list of` |
| `Nothing ->` | `[] ->` |
| `Just ( first, rest ) ->` | `first :: rest ->` |
| `String.cons x (...)` | `x :: (...)` |
| `""` | `[]` |

## 7. Higher-order functions: `map` and `filter`

Functions are ordinary values, so they can be passed as arguments.

| Function | Type | Example | Result |
|---|---|---|---|
| `List.map` | `(a -> b) -> List a -> List b` | `List.map (\x -> x * 2) [1,2,3]`<br>`List.map String.length ["ja","nee"]` | `[2,4,6]`<br>`[2,3]` |
| `List.filter` | `(a -> Bool) -> List a -> List a` | `List.filter Char.isAlpha ['a','!']` | `['a']` |

- `List.map f lst` applies `f` to **each** element and puts the results in a **new** list.
  The result type `b` may differ from `a`.
- `List.filter f lst` applies `f` to each element and keeps only those where `f` is `True`.
  Elements are never changed, so the type stays `a`.

Pass the function **by name**, without arguments; `map`/`filter` call it for you:

```elm
List.map sqr [1,2,3]     -- not  List.map (sqr x) [1,2,3]
```

A function taking a function as a parameter:

```elm
applyTwice : (a -> a) -> a -> a
applyTwice f x =
    f (f x)

-- applyTwice (\x -> x + 1) 5 == 7
```

**Parentheses matter in the signature:**

```elm
myFilter : (a -> Bool) -> List a -> List a   -- 2 params: a function and a list  ✅
myFilter : a -> Bool -> List a -> List a     -- 3 separate params                 ❌
```

Without the brackets, Elm reads the arrows as separate parameters (that's currying).
The brackets group `a -> Bool` into **one** parameter that is itself a function.

Writing your own versions is just the recursion patterns of §4 with `f` instead of a
hard-coded operation:

```elm
myMap : (a -> b) -> List a -> List b
myMap f lst =
    case lst of
        [] ->
            []

        first :: rest ->
            f first :: myMap f rest      -- = (f first) :: (myMap f rest)
```

Don't forget to pass `f` along in the recursive call.

## 8. The pipeline operator `|>`

```elm
x |> f          is exactly       f x
x |> f a b      is exactly       f a b x      -- the piped value becomes the LAST argument
```

| Example | Result |
|---|---|
| `5 \|> modBy 3` | `2` (same as `modBy 3 5`) |
| `"b" \|> String.append "a"` | `"ab"` (same as `String.append "a" "b"`) |
| `[1,2,3] \|> List.map (\x -> x * 2) \|> List.sum` | `12` |

Same result, same speed; it only changes **reading order** (top-to-bottom instead of
inside-out). Elm's core library deliberately puts the data argument last
(`List.map f list`, `String.cons c str`), which is why pipelines read so well.

```elm
modBy 10 (sumDigits (doubleSecond (toDigitsRev s)))       -- nested: read inside-out
toDigitsRev s |> doubleSecond |> sumDigits |> modBy 10    -- piped: read downwards
```

When in doubt, mentally rewrite `x |> f` as `f x`.

## 9. Partial application (preview of D: but used constantly here)

Every Elm function takes one argument at a time:
`encode : Int -> Char -> Char` really means `Int -> (Char -> Char)`.
Give it fewer arguments than it wants and you get back a **function waiting for the rest**.

| Example | Type / Result |
|---|---|
| `modBy 2` | `<function> : Int -> Int` |
| `List.map (modBy 2) [1,2,3,4]` | `[1,0,1,0]` |
| `List.map ((+) 3.5) [2,4,6]` | `[5.5,7.5,9.5]` |
| `List.map ((<) 3.5) [2,4,6]` | `[False,True,True]` (`(<) 3.5 x` means `3.5 < x`) |
| `List.filter ((<) 3.5) [2,4,6]` | `[4,6]` |

## 10. `List` function reference

| Function | Type | Example | Result |
|---|---|---|---|
| `List.map` | `(a -> b) -> List a -> List b` | `List.map (\x -> x * 2) [1,2,3]` | `[2,4,6]` |
| `List.filter` | `(a -> Bool) -> List a -> List a` | `List.filter (\x -> x > 1) [1,2,3]` | `[2,3]` |
| `List.head` | `List a -> Maybe a` | `List.head [42,73]` | `Just 42` |
| `List.length` | `List a -> Int` | `List.length [1,2,3]` | `3` |
| `List.isEmpty` | `List a -> Bool` | `List.isEmpty []` | `True` |
| `List.member` | `a -> List a -> Bool` | `List.member 3 [1,2,3]` | `True` |
| `List.range` | `Int -> Int -> List Int` | `List.range 1 5` | `[1,2,3,4,5]` |
| `List.reverse` | `List a -> List a` | `List.reverse [1,2,3]` | `[3,2,1]` |
| `List.sum` | `List number -> number` | `List.sum [1,2,3]` | `6` |
| `List.product` | `List number -> number` | `List.product [2,3,4]` | `24` |
| `List.minimum` | `List comparable -> Maybe comparable` | `List.minimum [3,1,2]`<br>`List.minimum []` | `Just 1`<br>`Nothing` |
| `List.maximum` | `List comparable -> Maybe comparable` | `List.maximum [3,1,2]` | `Just 3` |
| `List.any` | `(a -> Bool) -> List a -> Bool` | `List.any (\x -> x > 2) [1,2,3]` | `True` |
| `List.all` | `(a -> Bool) -> List a -> Bool` | `List.all (\x -> x > 2) [1,2,3]` | `False` |
| `List.append` | `List a -> List a -> List a` | `List.append [1] [2,3]` | `[1,2,3]` (same as `++`) |
| `List.concat` | `List (List a) -> List a` | `List.concat [[1],[2,3]]` | `[1,2,3]` |

(`List.foldl`, `List.foldr` and `List.partition` are in section C.)

## 11. Common compiler errors

| Message | Cause |
|---|---|
| "This `case` does not have branches for all possibilities" | missing `[]` or `Nothing` |
| `TYPE MISMATCH` `Char` vs `String` | wrong quotes, or `String.cons` vs `++` |
| `UNFINISHED PARENTHESES` | a function call written inside a pattern |
| Infinite loop / stack overflow | the recursive call didn't shrink the input |
| `NAMING ERROR` in the REPL | the function isn't in the module's `exposing (...)` list |
| Missing brackets | `f x (g y)`, not `f x g y` |
| Tuple patterns in lists | `( a, b, c ) :: rest`, not `a, b, c :: rest` |
