module Player where

import BasicTypes
import ListHelper
import Vector (Vector, addVector)


type PlayerId = Int
type Player = { pos: Vector, pid: PlayerId }

type State =
  { players: [Player],
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
  in { state | players <- map m state.players }

movePlayer : BasicTypes.Direction -> (Vector -> Bool) -> Player -> Player
movePlayer direction outOfBoardPredicate player =
    let
      d = {x = toFloat direction.x, y = toFloat direction.y}
      pos = addVector player.pos d
    in
      if outOfBoardPredicate pos
      then player
      else {player | pos <- pos}

showPlayer : (Vector -> Form -> Form) -> Float -> Player -> Form
showPlayer putObject r p = putObject p.pos <| filled red <| circle r

show : (Vector -> Form -> Form) -> Float -> State -> [Form]
show putObject r state = map (showPlayer putObject r) state.players
