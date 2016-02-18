module Main (..) where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


view : Signal.Address Action -> Game -> Html
view address game =
  div
    []
    (currentChapter address game :: pastChapters address game |> List.reverse)


currentChapter address game =
  chapterWithChoice address game.now


pastChapters address game =
  chaptersElem address game.past


chaptersElem : Signal.Address Action -> List Chapter -> List Html
chaptersElem address chapters =
  List.map (\s -> chaptElem address s.title s.body []) chapters


chapterWithChoice : Signal.Address Action -> Chapter -> Html
chapterWithChoice address chapter =
  chaptElem address chapter.title chapter.body chapter.choices


chaptElem : Signal.Address Action -> String -> String -> List Choice -> Html
chaptElem address title body choices =
  div
    []
    [ h1
        []
        [ text title ]
    , p
        []
        [ text body ]
    , choicesElem address choices
    ]


choicesElem : Signal.Address Action -> List Choice -> Html
choicesElem address choices =
  ul
    []
    (List.map (choiceElem address) choices)


choiceElem : Signal.Address Action -> Choice -> Html
choiceElem address choice =
  li
    []
    [ a
        [ href "#"
        , onClick address (Goto choice.id)
        ]
        [ text choice.text ]
    ]



-- Model


type alias Story =
  List Chapter


type alias Chapter =
  { id : Int, title : String, body : String, choices : List Choice }


type alias Game =
  { story : Story, past : List Chapter, now : Chapter }


type alias Choice =
  { id : Int, text : String }


chapter1 : Chapter
chapter1 =
  { id = 1
  , title = "Chapter 1"
  , body = "Once upon a time"
  , choices =
      [ { id = 1, text = "Choice 1" }
      , { id = 2, text = "Choice 2" }
      ]
  }


chapter2 : Chapter
chapter2 =
  { id = 2
  , title = "Chapter 2"
  , body = "The prince ..."
  , choices =
      [ { id = 2, text = "Choice 2" }
      , { id = 3, text = "Choice 3" }
      ]
  }


chapter3 : Chapter
chapter3 =
  { id = 3
  , title = "Chapter 3"
  , body = "The prince ..."
  , choices =
      [ { id = 1, text = "Chapter 1" }
      , { id = 2, text = "Chapter 2" }
      , { id = 4, text = "Chapter 4" }
      ]
  }


chapter4 : Chapter
chapter4 =
  { id = 4
  , title = "Chapter 4"
  , body = "and they lived happily. The End"
  , choices = []
  }


initGame : Game
initGame =
  { story = [ chapter1, chapter2, chapter3, chapter4 ]
  , past = []
  , now = chapter1
  }



-- update


type Action
  = NoOp
  | Goto Int


update : Action -> Game -> Game
update action game =
  case action of
    NoOp ->
      game

    Goto id ->
      let
        filtered =
          List.filter (\n -> n.id == id) game.story

        selected =
          List.head filtered
      in
        case selected of
          Nothing ->
            game

          Just chapter ->
            { game
              | past = game.now :: game.past
              , now = chapter
            }


app : Signal.Mailbox Action
app =
  Signal.mailbox NoOp



-- Model


main : Signal Html



-- main = view initGame


main =
  Signal.foldp update initGame app.signal |> Signal.map (view app.address)



-- Display a list
-- Click on a choice should display the new Chapter

