module Stamper where

import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import List
import List exposing ((::))
import Mouse
import Signal
import Window


main : Signal Element
main =
  Signal.map2 renderStamps Window.dimensions clickLocations

clickLocations : Signal (List (Int,Int))
clickLocations =
  Signal.foldp (::) [] (Signal.sampleOn Mouse.clicks Mouse.position)

renderStamps : (Int,Int) -> List (Int,Int) -> Element
renderStamps (w,h) locs =
  let pentagon (x,y) =
        ngon 3 20
          |> filled (hsla (toFloat x) 0.9 0.6 0.7)
          |> move (toFloat x - toFloat w / 2, toFloat h / 2 - toFloat y)
          |> rotate (toFloat x)
  in
      layers
        [ collage w h (List.map pentagon locs)
        , show "Click to stamp a pentagon."
        ]

