import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Mouse

mouse = Mouse.position

angle : (Int, Int) -> Int
angle (x, y) = x % 360

main : Signal Element
main =
    Signal.map action mouse
        
action (x,y) = 
    collage 300 300
        [polygons (toFloat (angle (x,y)))]

polygons angle =
  group [ 
    hexagon red red, 
    hexagon purple purple 
      |> rotate (degrees angle)
      |> scale 2, 
    hexagon red red|> rotate (degrees -angle)]

    

hexagon : Color -> Color -> Form
hexagon clr innerClr=
    ngon 6 40 |> filled innerClr
