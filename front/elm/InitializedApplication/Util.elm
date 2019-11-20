module InitializedApplication.Util exposing (..)

import BuilderApp.Model as BuilderApp
import InitializedApplication.Model exposing (..)
import Util.List as List
import List.Extra as List
import Application.Type exposing (..)

type alias Environment =
    { name : String
    , keyValues : Editable (List(String, String))
    }

replaceEnvironmentToEdit : Model -> Environment -> Model
replaceEnvironmentToEdit model newEnvironment =
    let newEnvironments =
            case model.selectedEnvironmentToEditIndex of
                Just idx ->
                    List.updateListAt model.environments idx (\formerEnvironment -> newEnvironment)
                Nothing ->
                    model.environments
    in
        { model | environments = newEnvironments }
