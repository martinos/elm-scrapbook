module Sort where

sort order whatTo items = 
  case order of  
    None ->
      items 
    Up ->
      List.sortBy whatTo items
    Down ->
      List.sortBy whatTo items |> List.reverse

toggle order =
  case order of
    None -> 
      Up
    Up ->
      Down
    Down ->
      Up 

type Order
  = None
  | Up
  | Down

