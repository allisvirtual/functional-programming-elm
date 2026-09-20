module Investments exposing (Money(..), split)


type Money
    = Euros Float
    | Dollars Float


isEuros : Money -> Bool
isEuros money =
    case money of
        Euros _ ->
            True

        Dollars _ ->
            False


split : List Money -> ( List Money, List Money )
split investments =
    List.partition isEuros investments



-- Example A:
-- > split [ Euros 10.5, Dollars 20, Euros 3, Dollars 7.25 ]
-- ([Euros 10.5,Euros 3],[Dollars 20,Dollars 7.25])
-- Example B:
-- > split [ Dollars 99 ]
-- ([],[Dollars 99])
