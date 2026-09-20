module Clock exposing (move)


move : Int -> ( Int, Int ) -> ( Int, Int )
move delta ( h, m ) =
    let
        totalMinutes =
            h * 60 + m

        newTime =
            modBy 1440 (totalMinutes + delta)
    in
    ( newTime // 60, modBy 60 newTime )
