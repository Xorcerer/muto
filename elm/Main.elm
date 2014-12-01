import Keyboard
import Window
import Char
import ListHelper (flatten)
import Vector (Vector, addVector)
import Bullet

-- TODO: seperate code to files, apply MVC to code.
type Player = { pos: Vector }

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
player = { pos = { x = 0, y = 0} }

myClamp = clamp -hbcpr (hbcpr - 1)
clampVector : Vector -> Vector
clampVector v = {v | x <- myClamp v.x, y <- myClamp v.y}

putObject : Vector -> Form -> Form
putObject pos = move (pos.x * cw + hcw, pos.y * cw + hcw)

outOfBoard v = myClamp v.x /= v.x || myClamp v.y /= v.y

movePlayer direction player =
    let d = {x = toFloat direction.x, y = toFloat direction.y} in
    {player | pos <- clampVector <| addVector player.pos d}

blueSquare : Form
blueSquare = filled lightBlue <| rect (cw - 1) (cw - 1)

showPlayer : Player -> Form
showPlayer p = putObject p.pos <| filled red <| circle hcw

seq n = [-n / 2..(n - 2) / 2]
getBoard x y = map (\y' -> map (\x' -> {x = x', y = y'}) (seq x)) (seq y)

board = map (\p -> putObject p blueSquare)
  <| flatten
  <| getBoard blockCountPerRow blockCountPerRow

playerState = foldp movePlayer player Keyboard.arrows

fireUnit = keepWhen Keyboard.space player (sampleOn Keyboard.space playerState)

bulletUpdate : Signal Bullet.Update
bulletUpdate = merge
  (lift (always Bullet.FrameUpdate) (fps 10))
  (lift (\p -> Bullet.FiredAt p.pos) fireUnit)

bullets = Bullet.initialize hcw outOfBoard

bulletState : Signal Bullet.State
bulletState = foldp Bullet.update bullets bulletUpdate

--state = {bulletState = Bullet.initialize hcw outOfBoard, }
display : (Int, Int) -> Player -> Bullet.State -> Element
display (w,h) p bs = container w h middle
  <| collage boardWidth boardWidth
  <| board ++ [showPlayer p] ++ Bullet.show putObject bs

main : Signal Element
main = lift3 display Window.dimensions playerState bulletState
