module Main (..) where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Task exposing (..)
import Json.Decode as Json
import StartApp exposing (..)


type alias Model =
  { topic : String
  , gifUrl : String
  }


init : String -> ( Model, Effects Action )
init topic =
  ( Model topic "assets/waiting.gif"
  , getRandomGif topic
  )


type Action
  = RequestMore
  | NewGif (Maybe String)


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    RequestMore ->
      ( model, getRandomGif model.topic ) |> Debug.log "Test"

    NewGif maybeUrl ->
      ( Model model.topic (Maybe.withDefault model.gifUrl maybeUrl)
      , Effects.none
      )


view address model =
  div
    []
    [ h2 [] [ text "Coucou" ]
    , img [ src model.gifUrl ] []
    , button [ onClick address RequestMore ] [ text "More Please" ]
    ]


getRandomGif : String -> Effects Action
getRandomGif topic =
  Http.get decodeUrl (randomUrl topic)
    |> Task.toMaybe
    |> Task.map NewGif
    |> Effects.task


randomUrl : String -> String
randomUrl topic =
  Http.url
    "http://api.giphy.com/v1/gifs/random"
    [ ( "api_key", "dc6zaTOxFJmzC" )
    , ( "tag", topic )
    ]


decodeUrl : Json.Decoder String
decodeUrl =
  Json.at [ "data", "image_url" ] Json.string


app =
  StartApp.start
    { init = init "funny cats"
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

