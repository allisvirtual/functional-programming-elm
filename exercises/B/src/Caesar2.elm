module Caesar2 exposing (decode, decrypt, encode, encrypt, normalize)


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
