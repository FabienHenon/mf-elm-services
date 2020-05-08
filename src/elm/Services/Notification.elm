port module Services.Notification exposing (notify)

import Http.Error
import Json.Encode as JE
import RemoteData
import Services.Data as Data


notify : String -> RemoteData.RemoteData Http.Error.RequestError a -> Bool -> Cmd msg
notify message res mustNotify =
    if mustNotify then
        portNotify (Data.payload Nothing message res)

    else
        Cmd.none



-- port to show a notification


port portNotify : JE.Value -> Cmd msg
