import Keyboard
import Window
import Char


flatten l =
    case l of
        [] -> []
        h::t -> h ++ flatten t

type Player = {x : Float, y : Float}

type Bullet = {x: Float, y: Float, dx: Float, dy: Float}


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
player = {x = 0, y = 0}

bullets : [Bullet]
bullets = []

myClamp = clamp -hbcpr (hbcpr - 1)

movePlayer d player = {player | x <- myClamp player.x + toFloat d.x,
                                y <- myClamp player.y + toFloat d.y}

fire : {x: Float, y:Float} -> {x: Float, y: Float} -> Bullet
fire position direction = {x = position.x, y = position.y, dx = direction.x, dy = direction.y}

updateBullets : [Bullet] -> [Bullet]
updateBullets bullets = filterMap updateBullet bullets

updateBullet : Bullet -> Maybe Bullet
updateBullet b = let newBullet = {x = b.x + b.dx, y = b.y + b.dy, dx = b.dx, dy = b.dy}
                in if (/=) (myClamp newBullet.x) newBullet.x || (/=) (myClamp newBullet.x) newBullet.x
                    then Nothing
                    else Just newBullet

updateBullet_ : Player -> Bullet -> Bullet
updateBullet_ player bullet = {bullet | x <- player.x, y <- player.y}

square : Path
square = path [(hcw, hcw), (hcw,-hcw), (-hcw,-hcw), (-hcw,hcw), (hcw, hcw)]

blueSquare : Form
blueSquare = traced (solid blue) square

showPlayer : Player -> Form
showPlayer p =
  move (p.x * cw + hcw, p.y * cw + hcw)
  <| filled red
  <| circle hcw

showBullets : [Bullet] -> [Form]
showBullets bs = map showBullet bs

showBullet : Bullet -> Form
showBullet b =
  move (b.x * cw + hcw, b.y * cw + hcw)
  <| filled blue
  <| circle hcw

seq n = map ((*) cw) [-n / 2..(n - 1) / 2]
getBoard x y = map (\y' -> map (\x' -> (x', y')) (seq x)) (seq y)

board = map (\p -> move p blueSquare)
  <| flatten
  <| getBoard blockCountPerRow blockCountPerRow

bullet = fire {x = 0, y = 0} {x = 0, y = 0}
playerState = foldp movePlayer player Keyboard.arrows

bulletsState : Signal Bullet
bulletsState = sampleOn (Keyboard.isDown (Char.toCode ' ')) (foldp updateBullet_ bullet playerState)

display : (Int, Int) -> Player -> Bullet -> Element
display (w,h) p bs = container w h middle
  <| collage boardWidth boardWidth
  <| board ++ [showPlayer p] ++ (showBullets [bs])

main : Signal Element
main = lift3 display Window.dimensions playerState bulletsState
