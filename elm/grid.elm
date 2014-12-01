import Keyboard
import Window
import Char


-- TODO: seperate code to files, apply MVC to code.
flatten l =
    case l of
        [] -> []
        h::t -> h ++ flatten t

type Vector = { x : Float, y : Float }

addVector : Vector -> Vector -> Vector
addVector v1 v2 = {v1 | x <- v1.x + v2.x, y <- v1.y + v2.y}

type Player = { pos: Vector }
type Bullet = { pos: Vector, direction: Vector }


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

bullets : [Bullet]
bullets = []

myClamp = clamp -hbcpr (hbcpr - 1)
clampVector : Vector -> Vector
clampVector v = {v | x <- myClamp v.x, y <- myClamp v.y}

putObject : Vector -> Form -> Form
putObject pos = move (pos.x * cw + hcw, pos.y * cw + hcw)

outOfBoard x = myClamp x /= x
movePlayer direction player =
    let d = {x = toFloat direction.x, y = toFloat direction.y} in
    {player | pos <- clampVector <| addVector player.pos d}

fire : Player -> {x: Float, y: Float} -> Bullet
fire p d = { pos = p.pos, direction = d}

updateBullets : BulletUpdate -> [Bullet] -> [Bullet]
updateBullets event bullets =
  case event of
    FiredBy player -> fire player {x=0, y=1}::bullets
    Time -> filterMap updateBullet bullets

updateBullet : Bullet -> Maybe Bullet
updateBullet b = let newBullet = {b | pos <- addVector b.pos b.direction}
                in if outOfBoard newBullet.pos.x || outOfBoard newBullet.pos.y
                    then Nothing
                    else Just newBullet

square : Path
square = path [(hcw, hcw), (hcw, -hcw), (-hcw, -hcw), (-hcw, hcw), (hcw, hcw)]

blueSquare : Form
blueSquare = traced (solid blue) square

showPlayer : Player -> Form
showPlayer p =
  putObject p.pos
  <| filled red
  <| circle hcw

showBullets : [Bullet] -> [Form]
showBullets bs = map showBullet bs

showBullet : Bullet -> Form
showBullet b =
  putObject b.pos
  <| filled blue
  <| circle (hcw / 2)

seq n = map ((*) cw) [-n / 2..(n - 1) / 2]
getBoard x y = map (\y' -> map (\x' -> (x', y')) (seq x)) (seq y)

board = map (\p -> move p blueSquare)
  <| flatten
  <| getBoard blockCountPerRow blockCountPerRow

playerState = foldp movePlayer player Keyboard.arrows

-- TODO: combine arrow keys, space key, fps signals together.
data BulletUpdate = Time | FiredBy Player

spaceDown = Keyboard.isDown <| Char.toCode ' '
fireUnit = keepWhen spaceDown player (sampleOn spaceDown playerState)

bulletUpdate : Signal BulletUpdate
bulletUpdate = merge
  (lift (always Time) (fps 10))
  (lift FiredBy fireUnit)

bulletsState : Signal [Bullet]
bulletsState = foldp updateBullets bullets bulletUpdate

display : (Int, Int) -> Player -> [Bullet] -> Element
display (w,h) p bs = container w h middle
  <| collage boardWidth boardWidth
  <| board ++ [showPlayer p] ++ showBullets bs

main : Signal Element
main = lift3 display Window.dimensions playerState bulletsState
