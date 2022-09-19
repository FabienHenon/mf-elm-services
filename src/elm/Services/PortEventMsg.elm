module Services.PortEventMsg exposing (PortEventMsg, addMsg, getMsg, init, removeMsg)

import Dict exposing (Dict)


type alias PortEventMsg msg =
    Dict String msg


init : PortEventMsg msg
init =
    Dict.empty


addMsg : String -> msg -> PortEventMsg msg -> PortEventMsg msg
addMsg =
    Dict.insert


removeMsg : String -> PortEventMsg msg -> PortEventMsg msg
removeMsg =
    Dict.remove


getMsg : String -> PortEventMsg msg -> Maybe msg
getMsg =
    Dict.get
