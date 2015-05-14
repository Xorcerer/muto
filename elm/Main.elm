import Keyboard
import Window
import Graphics.Collage as GC
import Graphics.Element as GE
import Char
import Color
import Maybe exposing (withDefault, andThen)
import Vector exposing (Vector, addVector)
import Basics exposing (always)
import Bullet
import Signal
import Time

import ListHelper exposing (flatten)
import BasicTypes
import Player

type alias State = { playerState: Player.State, bulletState: Bullet.State }

type Update = Fire | FrameUpdate | Move BasicTypes.Direction


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

putObject : Vector -> GC.Form -> GC.Form
putObject pos = GC.move (pos.x * cw + hcw, pos.y * cw + hcw)

outOfBoard : Vector -> Bool
outOfBoard v = myClamp v.x /= v.x || myClamp v.y /= v.y

seq n = [-n / 2..(n - 2) / 2]
getBoard x y = List.map (\y' -> List.map (\x' -> {x = x', y = y'}) (seq x)) (seq y)

blueSquare : GC.Form
blueSquare = GC.filled Color.lightBlue <| GC.rect (cw - 1) (cw - 1)

board = List.map (\p -> putObject p blueSquare)
  <| flatten
  <| getBoard blockCountPerRow blockCountPerRow

input : Signal Update
input = Signal.mergeMany
  [ (Signal.map (always FrameUpdate) (Time.fps 10)),
    (Signal.map (always Fire) <| Signal.filter Basics.identity False Keyboard.space),
    (Signal.map Move Keyboard.arrows)]

update : Update -> State -> State
update u state =
  let
    pos = withDefault {x=0, y=0} (andThen (Player.find myPlayerId state.playerState) (\p -> Just p.pos) )
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

display : (Int, Int) -> State -> GE.Element
display (w,h) s = GE.container w h GE.middle
  <| GC.collage boardWidth boardWidth
  <| board ++ Player.show putObject hcw s.playerState ++ Bullet.show putObject (hcw / 2) s.bulletState

main : Signal GE.Element
main = Signal.map2 display Window.dimensions (Signal.foldp update state input)
