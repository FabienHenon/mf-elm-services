module Services.Data exposing (payload, payloadWithHttpRequestId)

import Http
import Http.Error
import Json.Encode as JE
import RemoteData


payload : Maybe JE.Value -> String -> Bool -> RemoteData.RemoteData Http.Error.RequestError a -> JE.Value
payload resValue message fromRealtime res =
    payloadWithHttpRequestId resValue message fromRealtime (res |> RemoteData.map (\v -> ( v, Nothing )))


payloadWithHttpRequestId : Maybe JE.Value -> String -> Bool -> RemoteData.RemoteData Http.Error.RequestError ( a, Maybe String ) -> JE.Value
payloadWithHttpRequestId resValue message fromRealtime res =
    case res of
        RemoteData.Success ( r, httpRequestId ) ->
            JE.object
                [ ( "type", JE.string "success" )
                , ( "message", JE.string message )
                , ( "resource", resValue |> Maybe.withDefault JE.null )
                , ( "fromRealtime", JE.bool fromRealtime )
                , ( "httpRequestId", httpRequestId |> Maybe.map JE.string |> Maybe.withDefault JE.null )
                ]

        RemoteData.Failure err ->
            JE.object
                ([ ( "type", JE.string "error" )
                 , ( "message", JE.string message )
                 , ( "resource", resValue |> Maybe.withDefault JE.null )
                 , ( "fromRealtime", JE.bool fromRealtime )
                 ]
                    ++ (case err of
                            Http.Error.HttpError httpErr ->
                                case httpErr of
                                    Http.BadUrl url ->
                                        [ ( "statusCode", JE.null )
                                        , ( "errorType", JE.string "BAD_URL" )
                                        , ( "details"
                                          , JE.list
                                                (\detail ->
                                                    JE.object
                                                        [ ( "url", JE.string detail )
                                                        ]
                                                )
                                                [ url ]
                                          )
                                        ]

                                    Http.Timeout ->
                                        [ ( "statusCode", JE.null )
                                        , ( "errorType", JE.string "TIMEOUT" )
                                        ]

                                    Http.NetworkError ->
                                        [ ( "statusCode", JE.null )
                                        , ( "errorType", JE.string "NETWORK_ERROR" )
                                        ]

                                    Http.BadStatus status ->
                                        [ ( "statusCode", JE.int status )
                                        , ( "errorType", JE.string "BAD_STATUS" )
                                        ]

                                    Http.BadBody body ->
                                        [ ( "statusCode", JE.null )
                                        , ( "errorType", JE.string "BAD_BODY" )
                                        , ( "details"
                                          , JE.list
                                                (\source ->
                                                    JE.object
                                                        [ ( "source", JE.string source )
                                                        ]
                                                )
                                                [ body ]
                                          )
                                        ]

                            Http.Error.JsonApiError errors ->
                                [ ( "statusCode", JE.null )
                                , ( "errorType", JE.string "JSONAPI_ERROR" )
                                , ( "details"
                                  , JE.list
                                        (\error ->
                                            JE.object
                                                [ ( "id", error.id |> Maybe.map JE.string |> Maybe.withDefault JE.null )
                                                , ( "links", error.links |> Maybe.map (JE.dict identity JE.string) |> Maybe.withDefault JE.null )
                                                , ( "status", error.status |> Maybe.map JE.string |> Maybe.withDefault JE.null )
                                                , ( "code", error.code |> Maybe.map JE.string |> Maybe.withDefault JE.null )
                                                , ( "title", error.title |> Maybe.map JE.string |> Maybe.withDefault JE.null )
                                                , ( "detail", error.detail |> Maybe.map JE.string |> Maybe.withDefault JE.null )
                                                , ( "source", error.source |> Maybe.withDefault JE.null )
                                                , ( "meta", error.meta |> Maybe.withDefault JE.null )
                                                ]
                                        )
                                        errors
                                  )
                                ]

                            Http.Error.CustomError error ->
                                [ ( "statusCode", JE.null )
                                , ( "errorType", JE.string "CUSTOM_ERROR" )
                                , ( "details"
                                  , JE.list
                                        (\detail ->
                                            JE.object
                                                [ ( "detail", JE.string detail )
                                                ]
                                        )
                                        [ error ]
                                  )
                                ]
                       )
                )

        _ ->
            JE.object []
