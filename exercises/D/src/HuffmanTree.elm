module HuffmanTree exposing
    ( Huffman(..)
    , alphabet
    , decode
    , encode
    )


type Huffman
    = Leaf Char
    | Node Huffman Huffman


alphabet : Huffman -> List Char
alphabet tree =
    case tree of
        Leaf leaf ->
            [ leaf ]

        Node left right ->
            [] ++ alphabet left ++ alphabet right


encode : Huffman -> Char -> Maybe String
encode tree char =
    case tree of
        Leaf leaf ->
            if leaf == char then
                Just ""

            else
                Nothing

        Node left right ->
            case encode left char of
                Just code ->
                    Just ("0" ++ code)

                Nothing ->
                    case encode right char of
                        Just code ->
                            Just ("1" ++ code)

                        Nothing ->
                            Nothing


decode : Huffman -> String -> Maybe Char
decode tree code =
    case tree of
        Leaf leaf ->
            if String.isEmpty code then
                Just leaf

            else
                Nothing

        Node left right ->
            case String.uncons code of
                Nothing ->
                    Nothing

                Just ( first, rest ) ->
                    if first == '0' then
                        decode left rest

                    else if first == '1' then
                        decode right rest

                    else
                        Nothing



{-
   EXAMPLE 1
   in:
       alphabet (Node (Node (Leaf 'a') (Node (Leaf 'h') (Leaf 'k'))) (Leaf 'e'))
   out:
       ['a', 'h', 'k', 'e']

   EXAMPLE 2
   in:
       encode (Node (Node (Leaf 'a') (Node (Leaf 'h') (Leaf 'k'))) (Leaf 'e')) 'h'
   out:
       Just "010"

   EXAMPLE 3
   in:
       decode (Node (Node (Leaf 'a') (Node (Leaf 'h') (Leaf 'k'))) (Leaf 'e')) "010"
   out:
       Just 'h'
-}
