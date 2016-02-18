module Main (..) where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import StartApp.Simple as StartApp
import String
import ViewHelper


type alias Review =
  { stars : Int
  , body : String
  , author : String
  }


type alias Model =
  { reviews : List Review
  , inputBody : String
  , inputAuthor : String
  , stars : Int
  }


initModel : Model
initModel =
  { reviews = []
  , stars = 1
  , inputBody = ""
  , inputAuthor = ""
  }


type Action
  = NoOp
  | UpdateBody String
  | UpdateAuthor String
  | UpdateStars String
  | Add



-- | UpdateStars content


update action model =
  case action of
    NoOp ->
      model

    UpdateBody content ->
      { model | inputBody = content }

    UpdateAuthor content ->
      { model | inputAuthor = content }

    UpdateStars content ->
      { model | stars = parseInt content }

    Add ->
      { model | reviews = (reviewFromModel model :: model.reviews) } |> clearReviews


reviewFromModel model =
  { body = model.inputBody, author = model.inputAuthor, stars = model.stars }


clearReviews model =
  { model | inputBody = "", inputAuthor = "", stars = 1 }


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ class "small-9 columns" ]
    [ ViewHelper.foundation
    , h3 [] [ text "Preview" ]
    , displayReviews model
    , displayReview model.stars model.inputBody model.inputAuthor
    , reviewForm address model
    ]


reviewForm : Signal.Address Action -> Model -> Html
reviewForm address model =
  div
    []
    [ select
        [ onChange address UpdateStars ]
        [ option [ value "1", selected (model.stars == 1) ] [ text "1 star" ]
        , option [ value "2" , selected (model.stars == 2) ] [ text "2 stars" ]
        , option [ value "3", selected (model.stars == 3)  ] [ text "3 stars" ]
        , option [ value "4", selected (model.stars == 4) ] [ text "4 stars" ]
        ]
    , label [ for "inputBody" ] [ text "Review" ]
    , textarea
        [ id "inputBody"
        , onInput address UpdateBody
        , value model.inputBody
        ]
        []
    , br [] []
    , label [ for "updateAuthor" ] [ text "Author" ]
    , input
        [ id "updateAuthor"
        , onInput address UpdateAuthor
        , value model.inputAuthor
        ]
        []
    , button
        [ onClick address Add ]
        [ text "Submit" ]
    ]


displayReview : Int -> String -> String -> Html
displayReview stars body author =
  p
    []
    [ strong [] [ text ((toString stars) ++ " stars. ") ]
    , text body
    , br [] []
    , text ("--" ++ author)
    ]


displayReviews model =
  ul
    []
    (model.reviews |> List.map (\rev -> li [] [ displayReview rev.stars rev.body rev.author ]))


main =
  StartApp.start ({ model = initModel, update = update, view = view })


onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address f =
  on "input" targetValue (\v -> Signal.message address (f v))


onChange address f =
  on "change" targetValue (\v -> Signal.message address (f v))


parseInt : String -> Int
parseInt string =
  case String.toInt string of
    Ok value ->
      value

    Err error ->
      0

