import Html exposing (..)
import Html.Events exposing (..)
import Task exposing (..)
import Http
import Json.Decode as Json exposing ((:=)) 
import Debug
import Regex exposing (..)

view seachAddress cities model  = 
  div [] 
      [ input [on "input" targetValue (Signal.message seachAddress)]
              []
      , br [] []
      , citiesElem cities ] 

citiesElem cities =
  let 
    elems = 
      case cities of
        Ok cities -> 
          cities |> List.map cityElem
        Err message -> 
          [text message]
  in
    ul  []
        elems 

cityElem city =
  li []
     [text city]

search = Signal.mailbox ""

cities : Signal.Mailbox (Result String (List String))
cities =
  Signal.mailbox (Err "Invalid postal code")

-- main

main = Signal.map2 (view search.address) cities.signal search.signal

-- zipCode port --

port zipCode:  Signal (Task x ())
port zipCode = search.signal |> Signal.map queryZip

queryZip: String -> Task x () 
queryZip string =
  toResult ( lookZip string ) `andThen` Signal.send cities.address

validate: String -> Task String String
validate query =
  if contains (regex "[A-Za-z]\\d[A-Za-z]") query
    then succeed ("http://api.zippopotam.us/ca/" ++ query)
    else fail "Invalid postal code" 

lookZip: String -> Task String (List String) 
lookZip query = 
  validate query `andThen` ( mapError (toString)  << Http.get places )

places =
  let place =
    Json.object2  (\city state -> city ++ ", " ++ state)
                  ("place name" := Json.string)
                  ("state"      := Json.string)
  in 
    "places" := Json.list place



