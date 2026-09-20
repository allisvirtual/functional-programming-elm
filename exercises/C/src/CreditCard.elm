module CreditCard exposing
    ( isValid
    , partitionCards
    )


charToDigit : Char -> Int
charToDigit c =
    Char.toCode c - Char.toCode '0'


toDigits : String -> List Int
toDigits s =
    String.toList s
        |> List.filter Char.isDigit
        |> List.map charToDigit


toDigitsRev : String -> List Int
toDigitsRev s =
    --    List.foldl (\digit acc -> digit :: acc) [] (toDigits s)
    List.foldl (::) [] (toDigits s)


doubleSecond : List Int -> List Int
doubleSecond lst =
    case lst of
        first :: second :: rest ->
            first :: 2 * second :: doubleSecond rest

        _ ->
            lst


digitSum : Int -> Int
digitSum n =
    if n < 10 then
        n

    else
        modBy 10 n + digitSum (n // 10)


sumDigits : List Int -> Int
sumDigits lst =
    List.foldl (\n acc -> acc + digitSum n) 0 lst


hasSixteenDigits : String -> Bool
hasSixteenDigits s =
    String.length s == 16 && List.length (toDigits s) == 16


luhnChecksum : String -> Int
luhnChecksum s =
    modBy 10 (sumDigits (doubleSecond (toDigitsRev s)))


isValid : String -> Bool
isValid s =
    hasSixteenDigits s && luhnChecksum s == 0


cardNumbers : List String
cardNumbers =
    [ "5256283618614517"
    , "5567798501168013"
    , "4532899082537349"
    , "6011141461689343"
    , "4716347184862961"
    , "4916950537496300"
    , "5191806268524120"
    , "6011063209139742"
    ]


partitionCards : ( List String, List String )
partitionCards =
    List.partition isValid cardNumbers
