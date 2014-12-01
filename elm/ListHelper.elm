module ListHelper where

flatten l =
    case l of
        [] -> []
        h::t -> h ++ flatten t
