module EnvironmentEdition.App exposing (..)

import List.Extra as List

import EnvironmentEdition.Message exposing (Msg(..))

import EnvironmentKeyValueEdition.App as EnvironmentKeyValueEdition
import EnvironmentEdition.Model exposing (..)
import EnvironmentEdition.Util exposing (..)
import Application.Type exposing (..)
import Api.Client as Client
import Http as Http

defaultEnvironment =
    { id = 0
    , name = "new environment"
    , keyValues = NotEdited []
    }

update : Msg -> Model a -> (Model a, Cmd Msg)
update msg model =
  case msg of
    SelectEnvToEdit idx ->
      let
          newModel =
              { model | selectedEnvironmentToEditIndex = Just idx }
      in
          (newModel, Cmd.none)

    Delete idx ->
      let
        newEnvironments = List.removeAt idx model.environments
        newSelectedEnvironmentToEditIndex =
          case model.selectedEnvironmentToEditIndex == Just idx of
            True -> Nothing
            False -> model.selectedEnvironmentToEditIndex

        newModel =
            { model
                | selectedEnvironmentToEditIndex = newSelectedEnvironmentToEditIndex
                , environments = newEnvironments
             }
      in
          (newModel, Cmd.none)

    AskEnvironmentCreation name ->
        let
            payload =
                { name = name
                }

            newMsg =
                Client.postEnvironment "" payload (newEnvironmentResultToMsg name)
        in
            (model, newMsg)

    EnvironmentCreated id name ->
        let
            newEnv =
                { id = id
                , name = name
                , keyValues = NotEdited []
                }

            newEnvironments =
                model.environments ++ [ defaultEnvironment ]

            newModel =
                { model | environments = newEnvironments }
        in
            (newModel, Cmd.none)

    ServerError ->
        Debug.todo "server error :-("

    Add ->
        let
            newEnvironments =
                model.environments ++ [ defaultEnvironment ]

            newModel =
                { model | environments = newEnvironments }

        in
            (newModel, Cmd.none)

    ShowRenameInput idx ->
        let
            newModel =
                { model | selectedEnvironmentToRenameIndex = Just idx }
        in
            (newModel, Cmd.none)

    AskRename idx name ->
        let
            payload =
                { name = name
                }

            newMsg =
                Client.putEnvironmentByEnvironmentId "" idx payload (updateEnvironmentResultToMsg idx name)
        in
            (model, newMsg)

    EnvironmentUpdated idx name ->
        let
            updateEnv old =
                { old | name = name }

            mNewEnvs =
                List.updateAt idx updateEnv model.environments

            newModel =
                { model
                    | selectedEnvironmentToRenameIndex = Nothing
                    , environments = mNewEnvs
                }
        in
            (newModel, Cmd.none)


    Rename idx newEnvironmentName ->
        let
            updateEnv old =
                { old | name = newEnvironmentName }

            mNewEnvs =
                List.updateAt idx updateEnv model.environments

            newModel =
                { model
                    | selectedEnvironmentToRenameIndex = Nothing
                    , environments = mNewEnvs
                }
      in
          (newModel, Cmd.none)


    ChangeName idx newEnvironmentName ->
        let
            updateEnv old =
                { old | name = newEnvironmentName }

            mNewEnvs =
                List.updateAt idx updateEnv model.environments

            newModel =
                { model
                    | environments = mNewEnvs
                }
      in
          (newModel, Cmd.none)


    EnvironmentKeyValueEditionMsg subMsg ->
        case getEnvironmentToEdit model of
            Nothing ->
                (model, Cmd.none)

            Just environment ->
                case EnvironmentKeyValueEdition.update subMsg environment of
                    newEnvironment ->
                        let
                            -- todo fix 0 -> should be model.selectedEnvironmentToEditIndex
                            newEnvironments = List.setAt 0 newEnvironment model.environments

                            newModel =
                                { model | environments = newEnvironments }

                        in
                            (newModel, Cmd.none)

newEnvironmentResultToMsg : String -> Result Http.Error Int -> Msg
newEnvironmentResultToMsg name result =
    case result of
        Ok id ->
            EnvironmentCreated id name

        Err error ->
            Debug.log "test" ServerError

updateEnvironmentResultToMsg : Int -> String -> Result Http.Error Client.NoContent -> Msg
updateEnvironmentResultToMsg id name result =
    case result of
        Ok Client.NoContent ->
            EnvironmentUpdated id name

        Err error ->
            Debug.todo "server error" ServerError
