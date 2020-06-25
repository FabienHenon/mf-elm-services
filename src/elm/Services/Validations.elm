module Services.Validations exposing (getFieldError, toErrors)

import Dict exposing (Dict)
import Http.Error
import RemoteData


getFieldError : fields -> List ( fields, String ) -> Maybe String
getFieldError field =
    List.filter (Tuple.first >> (==) field)
        >> List.head
        >> Maybe.map Tuple.second


toErrors : Dict String fields -> RemoteData.RemoteData Http.Error.RequestError a -> List ( fields, String )
toErrors fieldsMapping entity =
    case entity of
        RemoteData.Failure error ->
            Http.Error.getJsonApiErrors error
                |> List.filterMap (toLocalError fieldsMapping)

        _ ->
            []


toLocalError : Dict String fields -> ( String, String ) -> Maybe ( fields, String )
toLocalError fieldsMapping ( field, msg ) =
    Dict.get field fieldsMapping
        |> Maybe.map (\f -> ( f, msg ))
