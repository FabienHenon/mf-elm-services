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


getItemWithAfterEvent : PortEventMsg.PortEventMsg (String -> JE.Value -> msg) -> (String -> JE.Value -> msg) -> String -> ( PortEventMsg.PortEventMsg (String -> JE.Value -> msg), Cmd msg )
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


onItemAfterEvent : PortEventMsg.PortEventMsg (String -> JE.Value -> msg) -> (String -> msg) -> Sub msg
onItemAfterEvent storage ignoredEventMsg =
    portLocalStorageAfterEvent (fromItemAfterEvent storage ignoredEventMsg)


setItem : String -> JE.Value -> Cmd msg
setItem key value =
    portSetLocalStorageItem
        (JE.object
            [ ( "key", JE.string key )
            , ( "value", JE.value value )
            ]
        )


fromItemAfterEvent : PortEventMsg.PortEventMsg (String -> JE.Value -> msg) -> (String -> msg) -> JE.Value -> msg
fromItemAfterEvent storage ignoredEventMsg event =
    case JD.decodeValue itemDecoder event of
        Err err ->
            ignoredEventMsg ("Event decoder error : " ++ JD.errorToString err)

        Ok { ref, value } ->
            case storage |> PortEventMsg.getMsg ref of
                Nothing ->
                    ignoredEventMsg ("No msg stored with ref " ++ ref)

                Just msg ->
                    msg ref value


itemDecoder : JD.Decoder StorageItem
itemDecoder =
    JD.map2 StorageItem
        (JD.field "value" JD.value)
        (JD.field "ref" JD.string)



-- port for asking the value of the local storage item


port portGetLocalStorageItem : JE.Value -> Cmd msg



-- port for setting the value of the local storage item


port portSetLocalStorageItem : JE.Value -> Cmd msg



-- port for receiving the value we wanted in the local storage


port portLocalStorageAfterEvent : (JE.Value -> msg) -> Sub msg
