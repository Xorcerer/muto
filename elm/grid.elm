import Keyboard
import Window
import Char


-- TODO: seperate code to files, apply MVC to code.
flatten l =
    case l of
        [] -> []
        h::t -> h ++ flatten t

type Vector = { x : Float, y : Float }
type Player = { pos : Vector }

type Bullet = { x : Float, y : Float, dx: Float, dy: Float }


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

outOfBoard x = myClamp x /= x
movePlayer d player = {player | pos <- { x = myClamp player.pos.x + toFloat d.x,
                                         y = myClamp player.pos.y + toFloat d.y}}


fire : Player -> {x: Float, y: Float} -> Bullet
fire p direction = {x = p.pos.x, y = p.pos.y, dx = direction.x, dy = direction.y}

updateBullets : BulletUpdate -> [Bullet] -> [Bullet]
updateBullets event bullets =
  case event of
    FiredBy player -> fire player {x=0, y=1}::bullets
    Time -> filterMap updateBullet bullets

updateBullet : Bullet -> Maybe Bullet
updateBullet b = let newBullet = {x = b.x + b.dx, y = b.y + b.dy, dx = b.dx, dy = b.dy}
                in if outOfBoard newBullet.x || outOfBoard newBullet.y
                    then Nothing
                    else Just newBullet

square : Path
square = path [(hcw, hcw), (hcw, -hcw), (-hcw, -hcw), (-hcw, hcw), (hcw, hcw)]

blueSquare : Form
blueSquare = traced (solid blue) square

showPlayer : Player -> Form
showPlayer p =
  move (p.pos.x * cw + hcw, p.pos.y * cw + hcw)
  <| filled red
  <| circle hcw

showBullets : [Bullet] -> [Form]
showBullets bs = map showBullet bs

showBullet : Bullet -> Form
showBullet b =
  move (b.x * cw + hcw, b.y * cw + hcw)
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

fireUnit = sampleOn (Keyboard.isDown <| Char.toCode ' ') playerState

bulletUpdate : Signal BulletUpdate
bulletUpdate = merge
  (lift (always Time) (fps 2))
  (lift FiredBy fireUnit)

bulletsState : Signal [Bullet]
bulletsState = foldp updateBullets bullets bulletUpdate

display : (Int, Int) -> Player -> [Bullet] -> Element
display (w,h) p bs = container w h middle
  <| collage boardWidth boardWidth
  <| board ++ [showPlayer p] ++ showBullets bs

main : Signal Element
main = lift3 display Window.dimensions playerState bulletsState
