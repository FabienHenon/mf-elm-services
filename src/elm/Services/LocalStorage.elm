port module Services.LocalStorage exposing
    ( StorageItem
    , getItem
    , getItemWithAfterEvent
    , onItemAfterEvent
    , setItem
    )

import Json.Decode as JD
import Json.Encode as JE
import Services.PortEventMsg as PortEventMsg


type alias StorageItem =
    { ref : String
    , value : JD.Value
    }


getItem : String -> Cmd msg
getItem key =
    portGetLocalStorageItem
        (JE.object
            [ ( "key", JE.string key )
            ]
        )


getItemWithAfterEvent : PortEventMsg.PortEventMsg (JE.Value -> msg) -> (JE.Value -> msg) -> String -> ( PortEventMsg.PortEventMsg (JE.Value -> msg), Cmd msg )
getItemWithAfterEvent storage afterEventMsg key =
    let
        ref =
            JE.object
                [ ( "key", JE.string key )
                ]
                |> JE.encode 0

        fullPayload =
            JE.object
                [ ( "key", JE.string key )
                , ( "ref", JE.string ref )
                ]
    in
    ( PortEventMsg.addMsg ref afterEventMsg storage
    , portGetLocalStorageItem fullPayload
    )


onItemAfterEvent : (String -> msg) -> (String -> JE.Value -> msg) -> Sub msg
onItemAfterEvent ignoredEventMsg destMsg =
    portLocalStorageAfterEvent (fromItemAfterEvent ignoredEventMsg destMsg)


setItem : String -> JE.Value -> Cmd msg
setItem key value =
    portSetLocalStorageItem
        (JE.object
            [ ( "key", JE.string key )
            , ( "value", value )
            ]
        )


fromItemAfterEvent : (String -> msg) -> (String -> JE.Value -> msg) -> JE.Value -> msg
fromItemAfterEvent ignoredEventMsg destMsg event =
    case JD.decodeValue itemDecoder event of
        Err err ->
            ignoredEventMsg ("Event decoder error : " ++ JD.errorToString err)

        Ok { ref, value } ->
            destMsg ref value


itemDecoder : JD.Decoder StorageItem
itemDecoder =
    JD.map2 StorageItem
        (JD.field "ref" JD.string)
        (JD.field "value" JD.value)



-- port for asking the value of the local storage item


port portGetLocalStorageItem : JE.Value -> Cmd msg



-- port for setting the value of the local storage item


port portSetLocalStorageItem : JE.Value -> Cmd msg



-- port for receiving the value we wanted in the local storage


port portLocalStorageAfterEvent : (JE.Value -> msg) -> Sub msg
