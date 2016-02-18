module Main (..) where

import Http exposing (..)
import Html exposing (..)
import Task exposing (..)
import Json.Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StartApp exposing (start)


type alias Model =
  { textInput : String, err : String }


model =
  { textInput = "", err = "" }


view : Signal.Address Action -> Model -> Html
view address model =
  div
    []
    [ input
        [ onInput address UpdateInput ]
        []
    , button
        [ onClick slack.address model.textInput ]
        [ text "Add" ]
    , text model.err
    ]



-- Main
-- main = view Nothing model


app =
  Signal.mailbox NoOp


main =
  Signal.foldp update model app.signal |> Signal.map (view app.address)



-- StartApp.start {model = model, view = view, update = update}


slack =
  Signal.mailbox ""


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    UpdateInput content ->
      { model | textInput = content }

    QueryResponse resp ->
      case resp of
        Ok result ->
          { model | err = "" }

        Err error ->
          { model | err = (toString error) }


type Action
  = NoOp
  | UpdateInput String
  | QueryResponse (Result Http.Error String)


result : Signal.Mailbox (Result Error (String))
result =
  Signal.mailbox (Ok "Not sent")


port postSlack : Signal (Task x ())
port postSlack =
  slack.signal |> Signal.map (\str -> (slackPost str |> toResult) `Task.andThen` (\result -> Signal.send app.address (QueryResponse result)))

slackPost : String -> Task Error String
slackPost text =
  post
    (Json.Decode.string)
    "replacemewithhook"
    (Http.string (Encode.encode 2 (payload text)))


payload text =
  Encode.object [ ( "text", Encode.string text ), ( "icon_emoji", Encode.string ":ghost:" ) ]


onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address f =
  on "input" targetValue (\v -> Signal.message address (f v))



-- test sending ---


mypost : Decoder value -> String -> Body -> Task Error value
mypost decoder url body =
  let
    request =
      { verb = "POST"
      , headers = [ ( "Content-type", "application/json" ) ]
      , url = url
      , body = body
      }
  in
    Http.fromJson decoder (Http.send Http.defaultSettings request)

