module Extra exposing (..)


isPositive : Float -> Bool
isPositive n =
    n > 0


minimumGainA : List Float -> Maybe Float
minimumGainA lst =
    List.minimum (List.filter isPositive lst)


minimumGainB : List Float -> Maybe Float
minimumGainB lst =
    case lst of
        [] ->
            Nothing

        first :: rest ->
            if first > 0 then
                case minimumGainB rest of
                    Nothing ->
                        Just first

                    Just m ->
                        if first < m then
                            Just first

                        else
                            Just m

            else
                minimumGainB rest


myFilter : (a -> Bool) -> List a -> List a
myFilter func lst =
    case lst of
        [] ->
            []

        first :: rest ->
            if func first then
                first :: myFilter func rest

            else
                myFilter func rest


myMap : (a -> b) -> List a -> List b
myMap func lst =
    case lst of
        [] ->
            []

        first :: rest ->
            func first :: myMap func rest


sequence : Int -> Int -> List Int
sequence length start =
    if length > 0 then
        start :: sequence (length - 1) (start + 1)

    else
        []
