module Vector where

type Vector = { x : Float, y : Float }

addVector : Vector -> Vector -> Vector
addVector v1 v2 = {v1 | x <- v1.x + v2.x, y <- v1.y + v2.y}
