module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Signal
import StartApp.Simple as StartApp
import Sort


initModel =
  { items = [ "car 1", "car 2", "car 3" ]
  , inputDisplay = ""
  , sortOrder = Sort.None
  }


view address model =
  div
    []
    [ itemInputElem address model.inputDisplay
    , inputDisplay model.inputDisplay
    , ul
        []
        (model.items |> Sort.sort model.sortOrder identity |> List.map itemElem)
    ]


itemElem value =
  li
    []
    [ text value ]


itemInputElem address item =
  div
    []
    [ input
        [ type' "text", value item, onInput address UpdateInput ]
        []
    , button
        [ onClick address Add ]
        [ text "Add" ]
    , button
        [ onClick address ToggleSort ]
        [ text "order" ]
    , button
        [ onClick address Reset ]
        [ text "Reset" ]
    ]


inputDisplay toDisplay =
  p [] [ String.toUpper toDisplay |> text ]


type Action
  = UpdateInput String
  | Add
  | Reset
  | ToggleSort


update action model =
  case action of
    UpdateInput content ->
      { model | inputDisplay = content }

    Add ->
      { model
        | items = model.inputDisplay :: model.items
        , inputDisplay = ""
      }

    Reset ->
      initModel

    ToggleSort ->
      { model | sortOrder = Sort.toggle model.sortOrder }


main =
  StartApp.start { model = initModel, view = view, update = update }


onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address f =
  on "input" targetValue (\v -> Signal.message address (f v))

