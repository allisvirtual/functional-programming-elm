module Pythagoras exposing
    ( hyp
    , isTriple
    , isTripleTuple
    , leg1
    , leg2
    , pythTriple
    , sqr
    )


sqr : Int -> Int
sqr n =
    n * n


isTriple : Int -> Int -> Int -> Bool
isTriple a b c =
    a > 0 && b > 0 && c > 0 && sqr a + sqr b == sqr c


leg1 : Int -> Int -> Int
leg1 x y =
    sqr x - sqr y


leg2 : Int -> Int -> Int
leg2 x y =
    2 * y * x


hyp : Int -> Int -> Int
hyp x y =
    sqr x + sqr y


pythTriple : ( Int, Int ) -> ( Int, Int, Int )
pythTriple ( x, y ) =
    ( leg1 x y, leg2 x y, hyp x y )


isTripleTuple : ( Int, Int, Int ) -> Bool
isTripleTuple ( a, b, c ) =
    isTriple a b c
