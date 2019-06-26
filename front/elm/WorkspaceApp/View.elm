module WorkspaceApp.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import WorkspaceApp.Message exposing (..)
import WorkspaceApp.Model exposing (..)
import BuilderApp.Model as BuilderApp

view : Model -> Html Msg
view model =
    div [ id "workspaceApp", class "columns" ]
        ((List.indexedMap (viewEntry) model) ++ [ defaultView ])

viewEntry : Int -> (String, BuilderApp.Model) -> Html Msg
viewEntry idx (workspaceName, _) =
    div [ id "workspaceForm" ]
        [ input [ placeholder "workspace", onInput (RenameWorkspace idx), value workspaceName] []
        , a [ href "#", onClick (DeleteWorkspace idx)] [ text "-" ]
        ]

defaultView : Html Msg
defaultView =
    div [ onClick AddNewInput, class "centerHorizontal align-self-center" ]
        [ span [] [ text "test" ] ]