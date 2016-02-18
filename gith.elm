module Main (..) where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import StartApp as StartApp
import Effects exposing (..)
import Http
import Json.Decode as JD exposing ((:=))
import Task
import Maybe
import ViewHelper exposing (..)
import String
import Regex


type alias Model =
  { user : String, repos : List Repo, filter : String, matches : List Repo, err : List String }


initModel : Model
initModel =
  { user = "Martinos", repos = [], filter = "", err = [], matches = [] }


app =
  StartApp.start
    { init = ( initModel, getRepos initModel.user )
    , update = update
    , view = view
    , inputs = []
    }


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


main =
  app.html


type Action
  = NewRepos (Result (Http.Error) (List Repo))
  | Fetch
  | UpdateFilter String


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    NewRepos result ->
      case result of
        Ok repos ->
          ( { model | repos = repos, err = [] } |> resetFilter, Effects.none )

        Err error ->
          ( { model | err = [ toString error ] }, Effects.none )

    Fetch ->
      ( model, getRepos model.user )

    UpdateFilter filterStr ->
      if String.isEmpty filterStr then
        ( model |> resetFilter, Effects.none )
      else
        let
          matcher = filterStr |> searchRegEx

          matches = model.repos |> List.filter (Regex.contains matcher << .name)
        in
          ( { model
              | filter = filterStr
              , matches = matches
            }
          , Effects.none
          )


resetFilter model =
  { model | filter = "", matches = model.repos }


searchRegEx : String -> Regex.Regex
searchRegEx =
  (Regex.escape >> Regex.regex >> Regex.caseInsensitive)



-- Side effect


getRepos : String -> Effects Action
getRepos user =
  Http.get repoDecoder (repoUrl user)
    |> Task.toResult
    |> Task.map NewRepos
    |> Effects.task


repoUrl : String -> String
repoUrl user =
  Http.url
    ("https://api.github.com/users/" ++ user ++ "/repos")
    [ ( "per_page", "100" ) ]


type alias Repo =
  { name : String, html_url : String, language : Maybe String }


repoDecoder =
  JD.list
    (JD.object3
      Repo
      ("full_name" := JD.string)
      ("html_url" := JD.string)
      ("language" := (JD.maybe JD.string))
    )



-- View


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ class "small-6 small-offset-2 columns" ]
    [ foundation
    , h1 [] [ text model.user ]
    , alert model.err
    , label
        []
        [ text "search"
        , input
            [ value model.filter
            , onInput address UpdateFilter
            , autofocus True
            ]
            []
        ]
    , div
        []
        [ ul
            []
            (List.map itemHtml model.matches)
        ]
    ]


alert msg =
  if List.isEmpty msg then
    text ""
  else
    div [ class "alert-box alert" ] (msg |> List.map (\n -> li [] [ text n ]))


itemHtml item =
  li [] [ a [ href item.html_url ] [ text item.name ] ]

