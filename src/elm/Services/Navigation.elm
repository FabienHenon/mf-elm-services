port module Services.Navigation exposing
    ( block
    , unblock
    )

import Json.Encode as JE


block : Cmd msg
block =
    portBlockNavigation (JE.object [])


unblock : Cmd msg
unblock =
    portUnblockNavigation (JE.object [])



-- port to block maestro navigation


port portBlockNavigation : JE.Value -> Cmd msg



-- port to unblock maestro navigation


port portUnblockNavigation : JE.Value -> Cmd msg
