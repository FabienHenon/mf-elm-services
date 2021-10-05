module Services.Realtime exposing
    ( RealtimeData
    , RealtimeDataWithMetadata
    , RealtimeEvent(..)
    , onCurrentSessionMessage
    , onFilteredCurrentSessionMessage
    , onFilteredMessage
    , onMessage
    , subscribe
    , subscribeCurrentSession
    , unsubscribe
    , unsubscribeCurrentSession
    , withMetadata
    )

import Json.Decode as JD
import Json.Encode as JE
import Services.EventManager as EventManager


type RealtimeEvent
    = RealtimeEvent String
    | NoEvent


type alias RealtimeData =
    { metadata : Maybe JD.Value
    , event : RealtimeEvent
    }


type alias RealtimeDataWithMetadata a =
    { event : RealtimeEvent
    , metadata : a
    }


subscribe : String -> Cmd msg
subscribe topic =
    Cmd.batch
        [ EventManager.emit
            (EventManager.makeCustomEventName "realtime:subscribe-topic")
            (EventManager.withPayload
                (JE.object
                    [ ( "topic", JE.string ("realtime:" ++ topic) )
                    ]
                )
            )
        , EventManager.listen
            (EventManager.makeCustomEventName ("realtime:" ++ topic))
        ]


unsubscribe : String -> Cmd msg
unsubscribe topic =
    Cmd.batch
        [ EventManager.emit
            (EventManager.makeCustomEventName "realtime:unsubscribe-topic")
            (EventManager.withPayload
                (JE.object
                    [ ( "topic", JE.string ("realtime:" ++ topic) )
                    ]
                )
            )
        , EventManager.removeListener
            (EventManager.makeCustomEventName ("realtime:" ++ topic))
        ]


subscribeCurrentSession : Cmd msg
subscribeCurrentSession =
    EventManager.listen
        (EventManager.makeCustomEventName "session:current-session")


unsubscribeCurrentSession : Cmd msg
unsubscribeCurrentSession =
    EventManager.removeListener
        (EventManager.makeCustomEventName "session:current-session")


onMessage : String -> (String -> msg) -> (RealtimeData -> msg) -> Sub msg
onMessage topic ignoredEventMsg mapper =
    EventManager.onEvent
        (EventManager.makeCustomEventName ("realtime:" ++ topic))
        ignoredEventMsg
        realtimeDecoder
        mapper


onFilteredMessage : String -> (String -> msg) -> RealtimeEvent -> (RealtimeData -> msg) -> Sub msg
onFilteredMessage topic ignoredEventMsg filterEvent mapper =
    EventManager.onEvent
        (EventManager.makeCustomEventName ("realtime:" ++ topic))
        ignoredEventMsg
        realtimeDecoder
        (checkEvent ignoredEventMsg filterEvent mapper)


onCurrentSessionMessage : (String -> msg) -> (RealtimeData -> msg) -> Sub msg
onCurrentSessionMessage ignoredEventMsg mapper =
    EventManager.onEvent
        (EventManager.makeCustomEventName "session:current-session")
        ignoredEventMsg
        realtimeDecoder
        mapper


onFilteredCurrentSessionMessage : (String -> msg) -> RealtimeEvent -> (RealtimeData -> msg) -> Sub msg
onFilteredCurrentSessionMessage ignoredEventMsg filterEvent mapper =
    EventManager.onEvent
        (EventManager.makeCustomEventName "session:current-session")
        ignoredEventMsg
        realtimeDecoder
        (checkEvent ignoredEventMsg filterEvent mapper)


withMetadata : (String -> msg) -> JD.Decoder a -> (RealtimeDataWithMetadata a -> msg) -> RealtimeData -> msg
withMetadata ignoredEventMsg decoder mapper realtime =
    realtime.metadata
        |> Maybe.map 
            (JD.decodeValue decoder 
                >> Result.map (RealtimeDataWithMetadata realtime.event)
                >> Result.map mapper
                >> Result.mapError (\err -> ignoredEventMsg ("Event metadata decoder error : " ++ (JD.errorToString err)))
                >> resultToMessage
            )
        |> Maybe.withDefault (ignoredEventMsg "Event metadata not found")


resultToMessage : Result msg msg -> msg
resultToMessage result =
    case result of
        Ok msg ->
            msg
        
        Err msg ->
            msg


checkEvent : (String -> msg) -> RealtimeEvent -> (RealtimeData -> msg) -> RealtimeData -> msg
checkEvent ignoredEventMsg filterEvent mapper payload =
    if payload.event == filterEvent then
        mapper payload

    else
        ignoredEventMsg ("Event " ++ (getEventName filterEvent) ++ " does not match event " ++ (getEventName payload.event))


realtimeDecoder : JD.Decoder RealtimeData
realtimeDecoder =
    JD.map2 RealtimeData
        (JD.maybe (JD.field "metadata" JD.value))
        (JD.field "event" (JD.oneOf [ JD.string |> JD.map eventDecoder, JD.succeed NoEvent ]))


eventDecoder : String -> RealtimeEvent
eventDecoder =
    RealtimeEvent


getEventName : RealtimeEvent -> String
getEventName (RealtimeEvent event) =
    event
