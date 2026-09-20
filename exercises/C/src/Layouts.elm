module Layouts exposing (layoutA, layoutB, layoutC)

-- LAYOUT A


layoutA : List Int -> String
layoutA lst =
    case lst of
        [] ->
            "/"

        first :: rest ->
            "/" ++ String.fromInt first ++ layoutA rest



-- LAYOUT B


accLeft : Int -> String -> String
accLeft num str =
    str ++ String.fromInt num ++ "/"


initLeft : String
initLeft =
    "/"


layoutB : List Int -> String
layoutB =
    List.foldl accLeft initLeft



-- LAYOUT C


accRight : Int -> String -> String
accRight num str =
    "/" ++ String.fromInt num ++ str


initRight : String
initRight =
    "/"


layoutC : List Int -> String
layoutC =
    List.foldr accRight initRight
