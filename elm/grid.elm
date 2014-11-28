import Keyboard
import Window


flatten l =
    case l of
        [] -> []
        h::t -> h ++ flatten t

type Player = {x : Float, y : Float}

type Bullet = {x: Float, y: Float, dx: Float, dy: Float}


blockCountPerRow = 10
bcpr = blockCountPerRow
hbcpr = bcpr / 2

boardWidth = 800

cellWidth = boardWidth / blockCountPerRow

cw : Float
cw = cellWidth
hcw : Float
hcw = cw / 2

player : Player
player = {x = 0, y = 0}

myClamp = clamp -hbcpr (hbcpr - 1)

movePlayer d player = {player | x <- myClamp player.x + toFloat d.x,
                                y <- myClamp player.y + toFloat d.y}

fire : {x: Float, y:Float} -> {x: Float, y: Float} -> Bullet
fire position direction = {x = position.x, y = position.y, dx = direction.x, dy = direction.y}

updateBullet : Bullet -> Maybe Bullet
updateBullet b = let newBullet = {x = b.x + b.dx, y = b.y + b.dy, dx = b.dx, dy = b.dy}
                in if (/=) (myClamp newBullet.x) newBullet.x || (/=) (myClamp newBullet.x) newBullet.x
                    then Nothing
                    else Just newBullet

square : Path
square = path [ (hcw, hcw), (hcw,-hcw), (-hcw,-hcw), (-hcw,hcw), (hcw, hcw) ]

blueSquare : Form
blueSquare = traced (solid blue) square

getPlayerSquare : Player -> Form
getPlayerSquare p = move (p.x * cw + hcw, p.y * cw + hcw) (traced (solid red) square)

showBullet : Maybe Bullet -> Form
showBullet b = move (b.x, b.y) (traced (solid blue) square)

seq n = map ((*) cw) [-n / 2..(n - 1) / 2]
getBoard x y = map (\y' -> map (\x' -> (x', y')) (seq x)) (seq y)

board = map (\p -> move p blueSquare)
    (flatten (getBoard blockCountPerRow blockCountPerRow))

playerState = foldp movePlayer player Keyboard.arrows

display (w,h) p = container w h middle (collage boardWidth boardWidth (board ++ [getPlayerSquare p]))

main : Signal Element
main = lift2 display Window.dimensions playerState
