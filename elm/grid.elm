import Keyboard


flatten l =
    case l of
        [] -> []
        h::t -> h ++ flatten t

type Player = {x:Int, y:Int}
player : Player
player = {x = 0, y = 0}

movePlayer d player = {player | x <- player.x + d.x, y <- player.y + d.y}

cellWidth = 50
boardWidth = 900
cw = cellWidth

square : Path
square = path [ (cw,cw), (cw,-cw),
                (-cw,-cw), (-cw,cw),
                (cw,cw) ]

blueSquare : Form
blueSquare = traced (solid blue) square

seq n = map ((*) cw) [0..n]
board x y = map (\y' -> map (\x' -> move (x', y') blueSquare) (seq x)) (seq y)

main : Element
main = collage boardWidth boardWidth (flatten (board 10 10))

-- main = lift asText (foldp movePlayer player Keyboard.arrows)
