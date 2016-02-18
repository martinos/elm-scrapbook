module Main (..) where

import Graphics.Element exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Input.Field exposing (..)
import Signal
import Color
import Text
import String
import StartApp
import Html exposing (Attribute)
import Html.Attributes exposing (value)
import Html.Events exposing (on, onClick, targetValue)
import Debug


type Tree a
  = Empty
  | Node a (Tree a) (Tree a)


empty : Tree a
empty =
  Empty


singleton : a -> Tree a
singleton v =
  Node v Empty Empty


insert : comparable -> Tree comparable -> Tree comparable
insert x tree =
  case tree of
    Empty ->
      singleton x

    Node y left right ->
      if x > y then
        Node y left (insert x right)
      else if x < y then
        Node y (insert x left) right
      else
        tree


fromList : List comparable -> Tree comparable
fromList xs =
  List.foldl insert empty xs


displayTree : ( Float, Float ) -> Tree x -> List Form
displayTree ( x, y ) tree =
  case tree of
    Empty ->
      []

    Node v left right ->
      displayTree ( x - 25.0, y - 60.0 ) left
        ++ [ nodeForms v ( x, y ), nodeText v ( x, y ) ]
        ++ displayTree ( x + 25.0, y - 60.0 ) right


nodeForms v ( x, y ) =
  circle 20.0 |> filled Color.red |> move ( x, y )


nodeText v ( x, y ) =
  v
    |> toString
    |> Text.fromString
    |> Text.color Color.white
    |> text
    |> move ( x, y )



-- Main --


t1 =
  fromList [ 1, 2, 3 ]


t2 =
  fromList [ 21, 4, 23, 22, 45, 1, 3 ]


type Action
  = NoOp
  | Add
  | Update String


type alias Model =
  { input : String
  , nodes : List Int
  }


initModel : Model
initModel =
  { input = "", nodes = [ 2 ] }


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    Update content ->
      { model | input = content }

    Add ->
      { model | nodes = model.nodes ++ [ (parseInt model.input) ] } |> clearInput


clearInput model =
  { model | input = "" }


parseInt : String -> Int
parseInt string =
  case String.toInt string of
    Ok value ->
      value

    Err error ->
      0


app =
  Signal.mailbox NoOp


inputView address inputValue =
  Html.div
    []
    [ Html.input
        [ value inputValue
        , onInput address Update
        ]
        []
    , Html.button [ onClick address Add ] [ Html.text "Add" ]
    ]


treeElement : List Int -> Element
treeElement treeList =
  collage 300 300 (displayTree ( 0, 100 ) (fromList treeList))


view address model =
  Html.div
    []
    [ inputView app.address model.input
    , Html.fromElement (treeElement model.nodes)
    ]


main =
  Signal.foldp update initModel app.signal |> Signal.map (view app.address)



-- main = flow down [(Html.toElement 50 50 (inputView app.address "12")), treeDisplay t2]


onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address f =
  on "input" targetValue (\v -> Signal.message address (f v))

