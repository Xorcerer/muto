import Keyboard
import Window
import Char
import ListHelper (flatten)
import Vector (Vector, addVector)
import Bullet

-- TODO: seperate code to files, apply MVC to code.
type Player = { pos: Vector }
type Direction = {x: Int, y: Int}

type State = { player: Player, bulletState: Bullet.State }

data Update = Fire | FrameUpdate | Move Direction


blockCountPerRow = 10
bcpr = blockCountPerRow
hbcpr = bcpr / 2

boardWidth = 800

cellWidth = boardWidth / blockCountPerRow

cw : Float
cw = cellWidth

hcw : Float
hcw = cw / 2

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

input : Signal Update
input = merges
  [ (lift (always FrameUpdate) (fps 10)),
    (keepWhen Keyboard.space Fire <| lift (always Fire) Keyboard.space),
    (lift Move Keyboard.arrows)]

update : Update -> State -> State
update u state =
  case u of
    FrameUpdate ->
      {state |
        bulletState <- Bullet.update Bullet.FrameUpdate state.bulletState}
    Fire ->
      {state |
        bulletState <-
          Bullet.update (Bullet.FireAt state.player.pos) state.bulletState}
    Move d ->
      {state |
        player <- movePlayer d state.player}

player : Player
player = { pos = { x = 0, y = 0} }

bullets : Bullet.State
bullets = Bullet.initialize hcw outOfBoard

state = {bulletState = Bullet.initialize hcw outOfBoard, player = player}

display : (Int, Int) -> State -> Element
display (w,h) s = container w h middle
  <| collage boardWidth boardWidth
  <| board ++ [showPlayer s.player] ++ Bullet.show putObject s.bulletState

main : Signal Element
main = lift2 display Window.dimensions (foldp update state input)
