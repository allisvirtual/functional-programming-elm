module Expressions exposing
    ( Expression(..)
    , derivative
    , eval
    , print
    )


type Expression
    = Add Expression Expression
    | Mul Expression Expression
    | Exp Expression Int
    | Const Float
    | X


print : Expression -> String
print expression =
    case expression of
        X ->
            "x"

        Const num ->
            String.fromFloat num

        Exp expr num ->
            "(" ++ print expr ++ " ^ " ++ String.fromInt num ++ ")"

        Mul expr1 expr2 ->
            "(" ++ print expr1 ++ " * " ++ print expr2 ++ ")"

        Add expr1 expr2 ->
            "(" ++ print expr1 ++ " + " ++ print expr2 ++ ")"


eval : Float -> Expression -> Float
eval var expression =
    case expression of
        X ->
            var

        Const num ->
            num

        Exp expr num ->
            --power (eval var expr) num
            eval var expr ^ toFloat num

        Mul expr1 expr2 ->
            eval var expr1 * eval var expr2

        Add expr1 expr2 ->
            eval var expr1 + eval var expr2


derivative : Expression -> Expression
derivative expression =
    case expression of
        X ->
            Const 1

        Const _ ->
            Const 0

        Exp expr num ->
            Mul (Mul (Const (toFloat num)) (Exp expr (num - 1))) (derivative expr)

        Mul expr1 expr2 ->
            Add (Mul expr1 (derivative expr2)) (Mul (derivative expr1) expr2)

        Add expr1 expr2 ->
            Add (derivative expr1) (derivative expr2)



-- HELPERS
{-
   power : Float -> Int -> Float
   power base exp =
       if exp == 0 then
           1

       else if exp < 0 then
           1 / power base (negate exp)

       else
           base * power base (exp - 1)
-}
