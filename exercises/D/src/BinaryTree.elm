module BinaryTree exposing (BinaryTree(..), countA, countB, countBSimple)


type BinaryTree a b
    = Leaf b
    | Node a (BinaryTree a b) (BinaryTree a b)


countA : BinaryTree a b -> Int
countA tree =
    case tree of
        Leaf _ ->
            0

        Node _ left right ->
            1 + countA left + countA right


countB : BinaryTree a b -> Int
countB tree =
    case tree of
        Leaf _ ->
            1

        Node _ left right ->
            countB left + countB right


countBSimple : BinaryTree a b -> Int
countBSimple tree =
    countA tree + 1



{-
   EXAMPLE 1
   in:
       countA (Node "root" (Leaf 1) (Node "child" (Leaf 2) (Leaf 3)))
   out:
       2

   EXAMPLE 2
   in:
       countB (Node "root" (Leaf 1) (Node "child" (Leaf 2) (Leaf 3)))
   out:
       3
-}
