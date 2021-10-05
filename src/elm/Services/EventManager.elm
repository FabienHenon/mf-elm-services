port module Services.EventManager exposing
    ( Config
    , EntityName
    , EventName
    , Payload
    , StateName
    , emit
    , listen
    , makeCustomEventName
    , makeEventName
    , noPayload
    , onEvent
    , onEventWithoutPayload
    , removeListener
    , withPayload
    )

import Json.Decode as JD
import Json.Encode as JE


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


listen : EventName -> Cmd msg
listen (EventName eventName) =
    portAddEventListener (JE.object [ ( "eventName", JE.string eventName ) ])


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
            ignoredEventMsg ("Event decoder error : " ++ (JD.errorToString err))

        Ok { eventName, payload } ->
            if wantedEventName == eventName then
                case JD.decodeValue decoder payload of
                    Ok payload_ ->
                        mapper payload_

                    Err error ->
                        ignoredEventMsg ("Event payload decoder error : " ++ (JD.errorToString error))

            else
                ignoredEventMsg ("Bad event name " ++ wantedEventName ++ ", actual event name is " ++ eventName)


fromEventWithoutPayload : String -> (String -> msg) -> msg -> JE.Value -> msg
fromEventWithoutPayload wantedEventName ignoredEventMsg eventMsg event =
    case JD.decodeValue eventDecoder event of
        Err err ->
            ignoredEventMsg ("Event decoder error : " ++ (JD.errorToString err))

        Ok { eventName } ->
            if wantedEventName == eventName then
                eventMsg

            else
                ignoredEventMsg ("Bad event name " ++ wantedEventName ++ ", actual event name is " ++ eventName)


eventDecoder : JD.Decoder EventPayload
eventDecoder =
    JD.map2 EventPayload
        (JD.field "eventName" JD.string)
        (JD.field "payload" JD.value)



-- port for sending string events out to JavaScript


port portEmitEvent : JE.Value -> Cmd msg



-- port for listening string events out to JavaScript


port portAddEventListener : JE.Value -> Cmd msg



-- port for receiving payload from string events out to JavaScript


port portEventReceived : (JE.Value -> msg) -> Sub msg



-- port to remove an event listener


port portRemoveEventListener : JD.Value -> Cmd msg
