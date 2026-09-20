module Shapes exposing (..)


type Shape
    = Point
    | Circle Float
    | Rectangle Float Float


area : Shape -> Float
area shape =
    case shape of
        Point ->
            0

        Circle r ->
            pi * r * r

        Rectangle w h ->
            w * h
