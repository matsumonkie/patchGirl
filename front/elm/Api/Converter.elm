module Api.Converter exposing(..)

import Api.Generated as Back
import BuilderApp.Model as Front
import SignIn.Model as Front
import BuilderApp.Builder.Model as Front
import Application.Type exposing (..)
import Application.Type as Front
import Dict as Dict
import Tuple as Tuple


-- * request Collection


convertRequestCollectionFromBackToFront : Back.RequestCollection -> Front.RequestCollection
convertRequestCollectionFromBackToFront backRequestCollection =
    let
        (Back.RequestCollection id backRequestNodes) = backRequestCollection
    in
        Front.RequestCollection id (convertRequestNodesFromBackToFront backRequestNodes)

convertRequestNodesFromBackToFront : List Back.RequestNode -> List Front.RequestNode
convertRequestNodesFromBackToFront backRequestNodes =
    let
        convertRequestNodeFromBackToFront : Back.RequestNode -> Front.RequestNode
        convertRequestNodeFromBackToFront backRequestNode =
            case backRequestNode of
                Back.RequestFolder folder ->
                    Front.RequestFolder
                        { id = folder.requestNodeId
                        , name = NotEdited folder.requestNodeName
                        , open = not <| List.isEmpty folder.requestNodeChildren
                        , children = convertRequestNodesFromBackToFront folder.requestNodeChildren
                        }
                Back.RequestFile file ->
                    Front.RequestFile
                        { id = file.requestNodeId
                        , name = NotEdited file.requestNodeName
                        , isSaved = True
                        , httpUrl = NotEdited file.requestNodeHttpUrl
                        , httpMethod = NotEdited (convertMethodFromBackToFront file.requestNodeHttpMethod)
                        , httpHeaders = NotEdited file.requestNodeHttpHeaders
                        , httpBody = NotEdited file.requestNodeHttpBody
                        , requestComputationResult = Nothing
                        , showResponseView = False
                        }
    in
        List.map convertRequestNodeFromBackToFront backRequestNodes

-- * environment


convertEnvironmentFromBackToFront : Back.Environment -> Front.Environment
convertEnvironmentFromBackToFront { environmentId, environmentName, environmentKeyValues } =
    { id = environmentId
    , name = NotEdited environmentName
    , showRenameInput = False
    , keyValues = List.map convertEnvironmentKeyValueFromBackToFront environmentKeyValues
    }


-- * environment key values


convertEnvironmentKeyValueFromBackToFront : Back.KeyValue -> Front.Storable Front.NewKeyValue Front.KeyValue
convertEnvironmentKeyValueFromBackToFront { keyValueId, keyValueKey, keyValueValue } =
    Saved { id = keyValueId
          , key = keyValueKey
          , value = keyValueValue
          }

convertEnvironmentKeyValueFromFrontToBack : Front.Storable Front.NewKeyValue Front.KeyValue -> Back.NewKeyValue
convertEnvironmentKeyValueFromFrontToBack storable =
    case storable of
        New { key, value } ->
            { newKeyValueKey = key
            , newKeyValueValue = value
            }

        Saved { key, value } ->
            { newKeyValueKey = key
            , newKeyValueValue = value
            }

        Edited2 _ { key, value } ->
            { newKeyValueKey = key
            , newKeyValueValue = value
            }

-- * account

convertSessionFromBackToFront : Back.Session -> Front.Session
convertSessionFromBackToFront backSession =
    case backSession of
        Back.VisitorSession { sessionAccountId, sessionCsrfToken } ->
            Front.Visitor { id = sessionAccountId
                          , csrfToken = sessionCsrfToken
                          , signInEmail = ""
                          , signInPassword = ""
                          , signInErrors = []
                          , signUpEmail = ""
                          , signUpError = Nothing
                          , signUpMessage = Nothing
                          }

        Back.SignedUserSession { sessionAccountId, sessionCsrfToken, sessionEmail } ->
            Front.SignedUser
                { id = sessionAccountId
                , csrfToken = sessionCsrfToken
                , email = sessionEmail
                }

-- * sign up

convertSignUpFromFrontToBack : Front.SignUp -> Back.SignUp
convertSignUpFromFrontToBack { email } =
    Back.SignUp { signUpEmail = email }


-- * sign in


convertSignInFromFrontToBack : Front.SignIn -> Back.SignIn
convertSignInFromFrontToBack { email, password } =
       { signInEmail = email
       , signInPassword = password
       }


-- * initializePassword


convertInitializePasswordBackToFront : String -> String -> Int -> Back.InitializePassword
convertInitializePasswordBackToFront password signUpToken accountId =
   { initializePasswordAccountId = accountId
   , initializePasswordPassword = password
   , initializePasswordToken = signUpToken
   }


-- * request computation


convertRequestComputationResultFromBackToFront : Back.RequestComputationResult -> Front.RequestComputationResult
convertRequestComputationResultFromBackToFront backRequestComputationResult =
    case backRequestComputationResult of
        Back.RequestTimeout ->
            Front.RequestTimeout

        Back.RequestNetworkError ->
            Front.RequestNetworkError

        Back.RequestBadUrl ->
            Front.RequestBadUrl

        Back.GotRequestComputationOutput { requestComputationOutputStatusCode
                                         , requestComputationOutputHeaders
                                         , requestComputationOutputBody
                                         } ->
            Front.GotRequestComputationOutput
                { statusCode = requestComputationOutputStatusCode
                , statusText = ""
                , headers = Dict.fromList <| List.map (Tuple.mapFirst String.toLower) requestComputationOutputHeaders
                , body = requestComputationOutputBody
                }

convertRequestComputationInputFromFrontToFromBack : Front.RequestComputationInput -> Back.RequestComputationInput
convertRequestComputationInputFromFrontToFromBack frontRequestInput =
   { requestComputationInputMethod = convertMethodFromFrontToBack frontRequestInput.method
   , requestComputationInputHeaders = frontRequestInput.headers
   , requestComputationInputScheme = convertSchemeFromFrontToBack frontRequestInput.scheme
   , requestComputationInputUrl = frontRequestInput.url
   , requestComputationInputBody = frontRequestInput.body
   }

convertMethodFromBackToFront : Back.Method -> Front.Method
convertMethodFromBackToFront method =
    case method of
        Back.Get -> Front.Get
        Back.Post -> Front.Post
        Back.Put -> Front.Put
        Back.Delete -> Front.Delete
        Back.Patch -> Front.Patch
        Back.Head -> Front.Head
        Back.Options -> Front.Options

convertMethodFromFrontToBack : Front.Method -> Back.Method
convertMethodFromFrontToBack method =
    case method of
        Front.Get -> Back.Get
        Front.Post -> Back.Post
        Front.Put -> Back.Put
        Front.Delete -> Back.Delete
        Front.Patch -> Back.Patch
        Front.Head -> Back.Head
        Front.Options -> Back.Options

convertSchemeFromFrontToBack : Front.Scheme -> Back.Scheme
convertSchemeFromFrontToBack scheme =
    case scheme of
        Front.Http -> Back.Http
        Front.Https -> Back.Https
