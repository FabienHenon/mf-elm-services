module Services.Realtime exposing
    ( RealtimeData
    , RealtimeEvent(..)
    , onCurrentSessionMessage
    , onFilteredCurrentSessionMessage
    , onFilteredMessage
    , onMessage
    , subscribe
    , subscribeCurrentSession
    , unsubscribe
    , unsubscribeCurrentSession
    )

import Json.Decode as JD
import Json.Encode as JE
import Services.EventManager as EventManager


type RealtimeEvent
    = CustomEvent String
    | IndexEvent
    | MFEvent String
    | ShowEvent


type alias RealtimeData =
    { data : Maybe JD.Value
    , event : RealtimeEvent
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


onMessage : String -> msg -> (RealtimeData -> msg) -> Sub msg
onMessage topic ignoredEventMsg mapper =
    EventManager.onEvent
        (EventManager.makeCustomEventName ("realtime:" ++ topic))
        ignoredEventMsg
        realtimeDecoder
        mapper


onFilteredMessage : String -> msg -> RealtimeEvent -> (RealtimeData -> msg) -> Sub msg
onFilteredMessage topic ignoredEventMsg filterEvent mapper =
    EventManager.onEvent
        (EventManager.makeCustomEventName ("realtime:" ++ topic))
        ignoredEventMsg
        realtimeDecoder
        (checkEvent ignoredEventMsg filterEvent mapper)


onCurrentSessionMessage : msg -> (RealtimeData -> msg) -> Sub msg
onCurrentSessionMessage ignoredEventMsg mapper =
    EventManager.onEvent
        (EventManager.makeCustomEventName "session:current-session")
        ignoredEventMsg
        realtimeDecoder
        mapper


onFilteredCurrentSessionMessage : msg -> RealtimeEvent -> (RealtimeData -> msg) -> Sub msg
onFilteredCurrentSessionMessage ignoredEventMsg filterEvent mapper =
    EventManager.onEvent
        (EventManager.makeCustomEventName "session:current-session")
        ignoredEventMsg
        realtimeDecoder
        (checkEvent ignoredEventMsg filterEvent mapper)


checkEvent : msg -> RealtimeEvent -> (RealtimeData -> msg) -> RealtimeData -> msg
checkEvent ignoredEventMsg filterEvent mapper payload =
    if payload.event == filterEvent then
        mapper payload

    else
        ignoredEventMsg


realtimeDecoder : JD.Decoder RealtimeData
realtimeDecoder =
    JD.map2 RealtimeData
        (JD.maybe (JD.field "data" JD.value))
        (JD.field "event" (JD.string |> JD.map eventDecoder))


eventDecoder : String -> RealtimeEvent
eventDecoder event =
    case event of
        "index" ->
            IndexEvent

        "show" ->
            ShowEvent

        t ->
            if String.startsWith "mf:" t then
                MFEvent (String.dropLeft 3 t)

            else
                CustomEvent t
