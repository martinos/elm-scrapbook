module Main (..) where

import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Text exposing (..)
import Mouse


type alias Coor =
  ( Int, Int )


relativePosition : Coor -> Coor -> Coor
relativePosition ( offsetx, offsety ) ( x, y ) =
  ( x - offsetx, offsety - y )


type alias Card =
  { pos : Coor
  , size : Coor
  }


myCard : Card
myCard =
  { pos = ( 0, 0 ), size = ( 90, 90 ) }


insideCard : Card -> Coor -> Bool
insideCard card ( x, y ) =
  insideRect card.pos card.size ( x, y )


insideRect : Coor -> Coor -> Coor -> Bool
insideRect ( posx, posy ) ( width, height ) ( x, y ) =
  x > posx - width // 2 && x < posx + width // 2 && y > posy - height // 2 && y < posy + height // 2


cardForm : Color -> Form
cardForm color =
  rect (toFloat (fst myCard.size)) (toFloat (snd myCard.size)) |> filled color


cardColor : Coor -> Color
cardColor ( x, y ) =
  if insideCard myCard ( x, y ) then
    green
  else
    blue


drawing ( x, y ) =
  collage
    300
    300
    [ cardForm (cardColor ( x, y ))
    , toString ( x, y )
        |> Text.fromString
        |> Text.color white
        |> text
    ]


mouse =
  Mouse.position


main =
  Signal.map drawing (Signal.map (relativePosition ( 150, 150 )) mouse)

