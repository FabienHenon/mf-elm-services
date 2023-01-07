port module Services.ExecScript exposing (exec)

import Json.Encode as JE


exec : String -> JE.Value -> Cmd msg
exec funcName variables =
    portExecScript
        (JE.object
            [ ( "funcName", JE.string funcName )
            , ( "variables", variables )
            ]
        )



-- port for setting the value of the local storage item


port portExecScript : JE.Value -> Cmd msg
