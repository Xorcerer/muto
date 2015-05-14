module Player where

import Color
import BasicTypes
import ListHelper
import List
import Vector exposing (Vector, addVector)
import Graphics.Collage as GC

type alias PlayerId = Int
type alias Player = { pos: Vector, pid: PlayerId }

type alias State =
  { players: List(Player),
    outOfBoardPredicate: Vector -> Bool
  }

initialize : (Vector -> Bool) -> State
initialize outOfBoardPredicate =
  { outOfBoardPredicate = outOfBoardPredicate,
    players = []
  }

find : PlayerId -> State -> Maybe Player
find pid state = ListHelper.find (\p -> p.pid == pid) state.players

add : Vector -> PlayerId -> State -> State
add p pid state = {state | players <- {pos = p, pid = pid} :: state.players}

move : BasicTypes.Direction -> PlayerId -> State -> State
move d pid state =
  let
    m player =
      if player.pid == pid
      then movePlayer d state.outOfBoardPredicate player
      else player
  in { state | players <- List.map m state.players }

movePlayer : BasicTypes.Direction -> (Vector -> Bool) -> Player -> Player
movePlayer direction outOfBoardPredicate player =
    let
      d = {x = toFloat direction.x, y = toFloat direction.y}
      pos = addVector player.pos d
    in
      if outOfBoardPredicate pos
      then player
      else {player | pos <- pos}

showPlayer : (Vector -> GC.Form -> GC.Form) -> Float -> Player -> GC.Form
showPlayer putObject r p = putObject p.pos
  <| GC.filled Color.red
  <| GC.circle r

show : (Vector -> GC.Form -> GC.Form) -> Float -> State -> List(GC.Form)
show putObject r state = List.map (showPlayer putObject r) state.players
