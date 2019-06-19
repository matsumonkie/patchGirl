module WorkspaceApp.App exposing (..)

import List.Extra as List

import WorkspaceApp.Model exposing (..)
import WorkspaceApp.Message exposing (Msg(..))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        RenameWorkspace idx str ->
            let
                newModel = List.updateAt idx (\_ -> str) model
            in
                (newModel, Cmd.none)

        DeleteWorkspace idx ->
            let
                newModel = List.removeAt idx model
            in
                (newModel, Cmd.none)

        AddNewInput ->
            let
                newModel = model ++ [""]
            in
                (newModel, Cmd.none)
