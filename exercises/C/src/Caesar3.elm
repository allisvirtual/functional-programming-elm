module Caesar3 exposing
    ( candidates
    , containsList
    , decode
    , decrypt
    , encode
    , encrypt
    , normalize
    )


shiftChar : Int -> Char -> Char -> Char
shiftChar key base c =
    let
        baseCode =
            Char.toCode base

        shifted =
            modBy 26 (Char.toCode c - baseCode + key)
    in
    Char.fromCode (shifted + baseCode)


encode : Int -> Char -> Char
encode key c =
    if Char.isLower c then
        shiftChar key 'a' c

    else if Char.isUpper c then
        shiftChar key 'A' c

    else
        c


decode : Int -> Char -> Char
decode key c =
    encode -key c



-- PART II


normalize : String -> String
normalize str =
    case String.uncons str of
        Nothing ->
            ""

        Just ( first, rest ) ->
            if Char.isAlpha first then
                String.cons first (normalize rest)

            else
                normalize rest


encrypt : Int -> String -> String
encrypt shift str =
    case String.uncons str of
        Nothing ->
            ""

        Just ( first, rest ) ->
            String.cons (encode shift first) (encrypt shift rest)


decrypt : Int -> String -> String
decrypt shift str =
    encrypt -shift str



-- PART III


startsWith : String -> String -> Bool
startsWith search target =
    case ( String.uncons search, String.uncons target ) of
        ( Nothing, _ ) ->
            True

        ( _, Nothing ) ->
            False

        ( Just ( s, restS ), Just ( t, restT ) ) ->
            s == t && startsWith restS restT


contains : String -> String -> Bool
contains search target =
    case String.uncons target of
        Nothing ->
            False

        Just ( _, restT ) ->
            startsWith search target || contains search restT


containsList : List String -> String -> Bool
containsList canaries target =
    case canaries of
        [] ->
            False

        first :: rest ->
            contains first target || containsList rest target


candidates : List String -> String -> List ( Int, String )
candidates canaries encrypted =
    List.range 1 25
        |> List.map (\key -> ( key, decrypt key encrypted ))
        |> List.filter (\( _, decrypted ) -> containsList canaries decrypted)



-- Example A:
-- > candidates ["THE"] "ESPBFTNVMCZHYQZIUFXADZGPCESPWLKJOZR"
-- [(11,"THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG")]
-- Example B:
-- > candidates ["AND", "THE"] "TIERYXFYXXIVERHNIPPCWERHAMGL"
-- [(4,"PEANUTBUTTERANDJELLYSANDWICH")]
