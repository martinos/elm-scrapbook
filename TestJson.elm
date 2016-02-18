module TestJson where

import Json.Decode as Json exposing(..)
import Graphics.Element exposing (..)

type alias Item = {id: Int, name: String, price: Float, tags: List String}

-- main = show (decodeString decoder toParse)

decoder': Decoder (Item)
decoder' =
  object4 Item
          ("id" := int)
          ("name" := string)
          ("price" := float)
          ("tags" := (list Json.string))
