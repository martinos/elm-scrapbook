module TestElm (main) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import StartApp.Simple as StartApp
import Debug
import String
import Sort
import ViewHelper exposing (..)


type alias Model =
  { entries : List Entry
  , itemInput : String
  , countInput : String
  , search : String
  , entriesToDisplay : List String
  , countOrder : Sort.Order
  , textOrder : Sort.Order
  }


initialModel =
  { entries = [ { text = "laundry", count = 1 }, { text = "dishes", count = 2 } ]
  , itemInput = ""
  , countInput = ""
  , search = ""
  , entriesToDisplay = []
  , countOrder = Sort.None
  , textOrder = Sort.None
  }


type alias Entry =
  { text : String, count : Int }



-- View --
---- Inputs ----


inputSearchElem address inputText =
  div
    [ class "row collapse" ]
    [ div
        [ class "small-10 columns" ]
        [ label
            []
            [ text "Search"
            , input
                [ type' "text"
                , onInput address UpdateSearch
                , value inputText
                ]
                []
            ]
        ]
    ]


inputEntryElem address inputText countText =
  div
    [ class "row collapse" ]
    [ div
        [ class "small-4 columns" ]
        [ label
            []
            [ text "Add"
            , input
                [ type' "text"
                , onInput address UpdateInput
                , value inputText
                ]
                []
            ]
        ]
    , div
        [ class "small-2 columns small-offset-2" ]
        [ label
            []
            [ text "Count"
            , input
                [ type' "number"
                , onInput address UpdateCount
                , value countText
                ]
                []
            ]
        ]
    , div
        [ class "small-2 columns" ]
        [ label
            []
            [ a
                [ onClick address Add, class "button postfix" ]
                [ text "Add" ]
            ]
        ]
    ]


sortChar order =
  case order of
    Sort.None ->
      " "

    Sort.Up ->
      ">"

    Sort.Down ->
      "<"



---- list ----


itemListHeader address countOrder textOrder =
  thead
    []
    [ tr
        []
        [ th [ onClick address ToggleTextSortOrder ] [ text ("Item" ++ sortChar textOrder) ]
        , th [ onClick address ToggleCountSortOrder ] [ text ("Count" ++ sortChar countOrder) ]
        ]
    ]


itemElem entry =
  tr
    []
    [ td
        []
        [ text entry.text ]
    , td
        []
        [ text (toString entry.count) ]
    ]


itemListElem address countOrder textOrder entries =
  let
    totalCount = List.foldl (.count >> (+)) 0 entries

    countItem = tfoot [] [itemElem { text = "Total", count = totalCount }]

    header = itemListHeader address countOrder textOrder
  in
    table
      []
      (header :: List.map itemElem entries ++ [ countItem ])


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ class "row" ]
    [ foundation
    , div
        [ class "small-8 columns" ]
        [ inputSearchElem address model.search
        , inputEntryElem address model.itemInput model.countInput
        , itemListElem
            address
            model.countOrder
            model.textOrder
            (model.entries
              |> seachFilter model.search
              |> Sort.sort model.countOrder .count
              |> Sort.sort model.textOrder .text
            )
        ]
    ]



-- Update --


type Action
  = NoOp
  | Add
  | UpdateInput String
  | UpdateCount String
  | UpdateSearch String
  | ClearSearch
  | ToggleCountSortOrder
  | ToggleTextSortOrder


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    Add ->
      { model
        | entries = entryFromInputs model :: model.entries
        , itemInput = ""
        , countInput = ""
      }

    UpdateInput content ->
      { model | itemInput = content }

    UpdateSearch content ->
      { model | search = content }

    ClearSearch ->
      { model | search = "" }

    UpdateCount content ->
      { model | countInput = content }

    ToggleCountSortOrder ->
      { model
        | countOrder = Sort.toggle model.countOrder |> Debug.watch "countOrder"
        , textOrder = Sort.None
      }

    ToggleTextSortOrder ->
      { model
        | textOrder = Sort.toggle model.textOrder |> Debug.watch "textOrder"
        , countOrder = Sort.None
      }


entryFromInputs : Model -> Entry
entryFromInputs model =
  { text = model.itemInput, count = parseInt model.countInput }


seachFilter : String -> List Entry -> List Entry
seachFilter searchInput entries =
  if String.isEmpty searchInput then
    entries
  else
    entries |> List.filter (String.contains searchInput << .text)



--
-- Where all begin --


main =
  StartApp.start { model = initialModel, update = update, view = view }



-- Helpers


onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address contentToValue =
  on "input" targetValue (Signal.message address << contentToValue)


parseInt : String -> Int
parseInt string =
  case String.toInt string of
    Ok value ->
      value

    Err error ->
      0

