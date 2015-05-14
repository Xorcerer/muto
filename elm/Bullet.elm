module Bullet where

import Color
import List
import Graphics.Collage as GC
import Vector exposing (Vector, addVector)


type alias Bullet = { pos: Vector, direction: Vector }

type Update = FrameUpdate | FireAt Vector

type alias State =
  { bullets: List(Bullet),
    outOfBoardPredicate: Vector -> Bool
  }

initialize : (Vector -> Bool) -> State
initialize outOfBoardPredicate =
  { outOfBoardPredicate = outOfBoardPredicate,
    bullets = []
  }

fire : Vector -> Vector -> Bullet
fire p d = { pos = p, direction = d }

-- FIXME: putObject should not pass from outside, we should seperate View and model.
show : (Vector -> GC.Form -> GC.Form) -> Float -> State -> List(GC.Form)
show putObject radius {bullets} = List.map (showBullet putObject radius) bullets

showBullet : (Vector -> GC.Form -> GC.Form) -> Float -> Bullet -> GC.Form
showBullet putObject r b = putObject b.pos <| GC.filled Color.lightRed <| GC.circle r

update : Update -> State -> State
update event state =
  let bullets = case event of
    FireAt pos -> fire pos {x=0, y=1} :: state.bullets
    FrameUpdate -> List.filterMap (updateBullet state.outOfBoardPredicate) state.bullets
  in {state | bullets <- bullets}

updateBullet : (Vector -> Bool) -> Bullet -> Maybe Bullet
updateBullet outOfBoardPredicate b =
  let newBullet = {b | pos <- addVector b.pos b.direction} in
  if outOfBoardPredicate newBullet.pos
    then Nothing
    else Just newBullet
