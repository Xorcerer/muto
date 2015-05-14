module ListHelper where

flatten l =
    case l of
        [] -> []
        h::t -> h ++ flatten t


find : (a -> Bool) -> List(a) -> Maybe a
find predicate l =
  case l of
    [] -> Nothing
    h::l -> if predicate h then Just h else find predicate l
