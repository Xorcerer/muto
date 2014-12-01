module Bullet where


import Vector (Vector, addVector)


type Bullet = { pos: Vector, direction: Vector }

data Update = FrameUpdate | FiredAt Vector

type State =
  { bulletRadius: Float, bullets: [Bullet],
    outOfBoardPredicate: Vector -> Bool
  }

initialize : Float -> (Vector -> Bool) -> State
initialize bulletRedius outOfBoardPredicate =
  { bulletRadius = bulletRedius,
    outOfBoardPredicate = outOfBoardPredicate,
    bullets = []
  }

fire : Vector -> Vector -> Bullet
fire p d = { pos = p, direction = d}

show : (Vector -> Form -> Form) -> State -> [Form]
show putObject {bullets, bulletRadius} = map (showBullet putObject bulletRadius) bullets

showBullet : (Vector -> Form -> Form) -> Float -> Bullet -> Form
showBullet putObject r b = putObject b.pos <| filled lightRed <| circle (r / 2)

update : Update -> State -> State
update event state =
  let bullets = case event of
    FiredAt pos -> fire pos {x=0, y=1} :: state.bullets
    FrameUpdate -> filterMap (updateBullet state.outOfBoardPredicate) state.bullets
  in {state | bullets <- bullets}

updateBullet : (Vector -> Bool) -> Bullet -> Maybe Bullet
updateBullet outOfBoardPredicate b =
  let newBullet = {b | pos <- addVector b.pos b.direction} in
  if outOfBoardPredicate newBullet.pos
    then Nothing
    else Just newBullet
