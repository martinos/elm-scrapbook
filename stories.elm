module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- Model


type alias Story =
  { chapters : List Chapter, currentChapter : Chapter, error : String }


type alias Choice =
  { id : Int, text : String }


type alias Chapter =
  { text : String, choices : List Choice, id : Int }



-- View


view : Signal.Address Action -> Story -> Html
view address story =
  div
    []
    [ strong [] [ text story.error ]
    , chapterElem address story.currentChapter
    ]


chapterElem address chapter =
  div
    []
    [ p
        []
        [ text chapter.text
        , choicesList address chapter.choices
        ]
    ]


choicesList address choices =
  ul
    []
    (List.map (choiceElem address) choices)


choiceElem address choice =
  li
    []
    [ a [ onClick address (Goto choice.id) ] [ text choice.text ] ]



-- Model


firstChapter =
  { text = "This is the first chapter"
  , choices =
      [ { id = 2, text = "Go There" }
      , { id = 3, text = "Go There if you want a surprise" }
      ]
  , id = 1
  }


secondChapter =
  { text = "Tthis is the second chapter", choices = [ { id = 1, text = "Go Back To Start" } ], id = 2 }


thirdChapter =
  { text = "This is Chapter 3"
  , choices =
      [ { id = 2, text = "Go Back to Chapter 2" }
      , { id = 4, text = "Almost There" }
      ]
  , id = 3
  }


endChapter =
  { text = "This is the End", choices = [], id = 4 }


currentStory =
  { chapters = [ firstChapter, secondChapter, thirdChapter, endChapter ], currentChapter = firstChapter, error = "" }


type Action
  = NoOp
  | Goto Int


app =
  Signal.mailbox NoOp


update action story =
  case action of
    NoOp ->
      story

    Goto id ->
      case (fetchChapter story.chapters id) of
        Just a ->
          { story | currentChapter = a, error = "" }

        Nothing ->
          { story | error = "Invalid Link" ++ toString id }


fetchChapter chapters id =
  List.filter (\chapt -> chapt.id == id) chapters |> List.head


main =
  Signal.foldp update currentStory app.signal |> Signal.map (view app.address)

