port module Services.EventManager exposing
    ( Config
    , EntityName
    , EventName
    , Payload
    , StateName
    , emit
    , emitWithAfterEvent
    , listen
    , listenOnce
    , makeCustomEventName
    , makeEventName
    , noPayload
    , onEmitAfterEvent
    , onEvent
    , onEventWithoutPayload
    , removeListener
    , withPayload
    )

import Json.Decode as JD
import Json.Encode as JE
import Services.PortEventMsg as PortEventMsg
import Dict


type alias Config a =
    { a
        | domainName : String
    }


type alias StateName =
    String


type alias EntityName =
    String


type Payload
    = Payload (Maybe JE.Value)


type alias EventPayload =
    { eventName : String, payload : JE.Value }


type EventName
    = EventName String


makeCustomEventName : String -> EventName
makeCustomEventName =
    EventName


makeEventName : Config a -> EntityName -> StateName -> EventName
makeEventName { domainName } entity state =
    domainName ++ ":" ++ entity ++ ":" ++ state |> EventName


noPayload : Payload
noPayload =
    Payload Nothing


withPayload : JE.Value -> Payload
withPayload value =
    Payload (Just value)


emit : EventName -> Payload -> Cmd msg
emit (EventName eventName) (Payload payload) =
    portEmitEvent
        (JE.object
            [ ( "eventName", JE.string eventName )
            , ( "payload", Maybe.withDefault (JE.object []) payload )
            ]
        )


emitWithAfterEvent : PortEventMsg.PortEventMsg msg -> msg -> EventName -> Payload -> ( PortEventMsg.PortEventMsg msg, Cmd msg )
emitWithAfterEvent storage afterEventMsg (EventName eventName) (Payload payload) =
    let
        ref =
            JE.object
                [ ( "eventName", JE.string eventName )
                , ( "payload", Maybe.withDefault (JE.object []) payload )
                ]
                |> JE.encode 0

        fullPayload =
            JE.object
                [ ( "eventName", JE.string eventName )
                , ( "payload", Maybe.withDefault (JE.object []) payload )
                , ( "ref", JE.string ref )
                ]
    in
    ( PortEventMsg.addMsg ref afterEventMsg storage
    , portEmitEvent fullPayload
    )


onEmitAfterEvent : (String -> msg) -> (String -> msg) -> Sub msg
onEmitAfterEvent ignoredEventMsg destMsg =
    portEmitAfterEvent (fromEmitAfterEvent ignoredEventMsg destMsg)


listen : EventName -> Cmd msg
listen (EventName eventName) =
    portAddEventListener (JE.object [ ( "eventName", JE.string eventName ) ])


listenOnce : EventName -> Cmd msg
listenOnce (EventName eventName) =
    portAddEventListenerOnce (JE.object [ ( "eventName", JE.string eventName ) ])


removeListener : EventName -> Cmd msg
removeListener (EventName eventName) =
    portRemoveEventListener (JE.object [ ( "eventName", JE.string eventName ) ])


onEvent : EventName -> (String -> msg) -> JD.Decoder obj -> (obj -> msg) -> Sub msg
onEvent (EventName eventName) ignoredEventMsg decoder mapper =
    portEventReceived (fromEventPayload eventName ignoredEventMsg decoder mapper)


onEventWithoutPayload : EventName -> (String -> msg) -> msg -> Sub msg
onEventWithoutPayload (EventName eventName) ignoredEventMsg eventMsg =
    portEventReceived (fromEventWithoutPayload eventName ignoredEventMsg eventMsg)


fromEventPayload : String -> (String -> msg) -> JD.Decoder obj -> (obj -> msg) -> JE.Value -> msg
fromEventPayload wantedEventName ignoredEventMsg decoder mapper event =
    case JD.decodeValue eventDecoder event of
        Err err ->
            ignoredEventMsg ("Event decoder error : " ++ JD.errorToString err)

        Ok { eventName, payload } ->
            if wantedEventName == eventName then
                case JD.decodeValue decoder payload of
                    Ok payload_ ->
                        mapper payload_

                    Err error ->
                        ignoredEventMsg ("Event payload decoder error : " ++ JD.errorToString error)

            else
                ignoredEventMsg ("Bad event name " ++ wantedEventName ++ ", actual event name is " ++ eventName)


fromEventWithoutPayload : String -> (String -> msg) -> msg -> JE.Value -> msg
fromEventWithoutPayload wantedEventName ignoredEventMsg eventMsg event =
    case JD.decodeValue eventDecoder event of
        Err err ->
            ignoredEventMsg ("Event decoder error : " ++ JD.errorToString err)

        Ok { eventName } ->
            if wantedEventName == eventName then
                eventMsg

            else
                ignoredEventMsg ("Bad event name " ++ wantedEventName ++ ", actual event name is " ++ eventName)


fromEmitAfterEvent : (String -> msg) -> (String -> msg) -> JE.Value -> msg
fromEmitAfterEvent ignoredEventMsg destMsg event =
    case JD.decodeValue eventRefDecoder event of
        Err err ->
            ignoredEventMsg ("Event decoder error : " ++ JD.errorToString err)

        Ok ref ->
            destMsg ref


eventDecoder : JD.Decoder EventPayload
eventDecoder =
    JD.map2 EventPayload
        (JD.field "eventName" JD.string)
        (JD.field "payload" JD.value)


eventRefDecoder : JD.Decoder String
eventRefDecoder =
    JD.field "ref" JD.string



-- port for sending string events out to JavaScript


port portEmitEvent : JE.Value -> Cmd msg



-- port for listening string events out to JavaScript


port portAddEventListener : JE.Value -> Cmd msg



-- port for listening string events out to JavaScript


port portAddEventListenerOnce : JE.Value -> Cmd msg



-- port for receiving payload from string events out to JavaScript


port portEventReceived : (JE.Value -> msg) -> Sub msg



-- port to remove an event listener


port portRemoveEventListener : JD.Value -> Cmd msg



-- port to execute something ofter sending an event


port portEmitAfterEvent : (JE.Value -> msg) -> Sub msg
