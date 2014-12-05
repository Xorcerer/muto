import Keyboard
import Window
import Char
import Maybe (maybe)
import ListHelper (flatten)
import Vector (Vector, addVector)
import BasicTypes
import Bullet
import Player


type State = { playerState: Player.State, bulletState: Bullet.State }

data Update = Fire | FrameUpdate | Move BasicTypes.Direction


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

putObject : Vector -> Form -> Form
putObject pos = move (pos.x * cw + hcw, pos.y * cw + hcw)

outOfBoard : Vector -> Bool
outOfBoard v = myClamp v.x /= v.x || myClamp v.y /= v.y

seq n = [-n / 2..(n - 2) / 2]
getBoard x y = map (\y' -> map (\x' -> {x = x', y = y'}) (seq x)) (seq y)

blueSquare : Form
blueSquare = filled lightBlue <| rect (cw - 1) (cw - 1)

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
  let
    pos = maybe {x=0, y=0} .pos (Player.find myPlayerId state.playerState)
  in case u of
    FrameUpdate ->
      {state |
        bulletState <- Bullet.update Bullet.FrameUpdate state.bulletState}
    Fire ->
      {state |
        bulletState <- Bullet.update (Bullet.FireAt pos) state.bulletState}
    Move d ->
      {state | playerState <- Player.move d myPlayerId state.playerState}


myPlayerId = 1

playerState = Player.add {x=0, y=0} myPlayerId <| Player.initialize outOfBoard

state : State
state =
  { bulletState = Bullet.initialize outOfBoard,
    playerState = playerState}

display : (Int, Int) -> State -> Element
display (w,h) s = container w h middle
  <| collage boardWidth boardWidth
  <| board ++ Player.show putObject hcw s.playerState ++ Bullet.show putObject (hcw / 2) s.bulletState

main : Signal Element
main = lift2 display Window.dimensions (foldp update state input)
