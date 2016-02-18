import Markdown
import Graphics.Element exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

content : String
content = """

# Apple Pie Recipe

This is the text it self
  1. Invent the universe.
    2. Bake an apple pie.

```
10.times {|a| a}
```
"""

model = {content = content}


view address model =
  div []
      [ textarea [onInput address Input
                 , rows 20
                 , cols 50] [] 
      , div [style [("display", "inline-block")]] [Markdown.toHtml model.content]]

type Action
  = NoOp
  | Input String

update action model =
  case action of
  NoOp ->
    model
  Input text' ->
    {model | content = text'}

-- main = view Nothing model 
actions = Signal.mailbox NoOp


main = Signal.foldp update model actions.signal |> Signal.map (view actions.address)

onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address f =
      on "input" targetValue (\v -> Signal.message address (f v))
