module Caesar exposing (decode, encode)


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
