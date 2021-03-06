module Application.Type exposing (..)

type Session
    = Visitor VisitorSession
    | SignedUser { id: Int
                 , csrfToken: String
                 , email: String
                 }

type alias VisitorSession =
    { id: Int
    , csrfToken: String
    , signInEmail: String
    , signInPassword: String
    , signInErrors: List String
    , signUpEmail: String
    , signUpError: Maybe String
    , signUpMessage: Maybe String
    }

type alias SignUp =
    { email : String
    }

getCsrfToken : Session -> String
getCsrfToken session =
    case session of
        Visitor { csrfToken } -> csrfToken
        SignedUser { csrfToken } -> csrfToken

getSessionId : Session -> Int
getSessionId session =
    case session of
        Visitor { id } -> id
        SignedUser { id } -> id

type alias Environment =
    { id : Int
    , name : Editable String
    , showRenameInput : Bool
    , keyValues : List (Storable NewKeyValue KeyValue)
    }

type alias NewKeyValue =
    { key : String
    , value : String
    }

type alias KeyValue =
    { id : Int
    , key : String
    , value : String
    }

type Editable a
    = NotEdited a
    | Edited a a

type Storable a b
    = New a
    | Saved b
    | Edited2 b b

isDirty : Editable a -> Bool
isDirty editable =
    case editable of
        NotEdited _ ->
            False

        Edited _ _ ->
            True

isDirty2 : Storable a b -> Bool
isDirty2 storable =
    case storable of
        New _ ->
            True

        Edited2 _ _ ->
            True

        Saved _ ->
            False


editedOrNotEditedValue : Editable a -> a
editedOrNotEditedValue editable =
    case editable of
        NotEdited value ->
            value
        Edited _ newValue ->
            newValue

storedOrNotStoredValue : Storable a b -> (a -> c) -> (b -> c) -> c
storedOrNotStoredValue storable f g =
    case storable of
        New value ->
            f value

        Saved value ->
            g value

        Edited2 _ value ->
            g value

notEditedValue : Editable a -> a
notEditedValue editable =
    case editable of
        NotEdited value ->
            value
        Edited value _ ->
            value

editedValue : Editable a -> Maybe a
editedValue editable =
    case editable of
        NotEdited _ -> Nothing
        Edited _ value -> Just value

changeEditedValue : a -> Editable a -> Editable a
changeEditedValue newValue editable =
    let
        oldValue = notEditedValue editable
    in
        case oldValue == newValue of
            True ->
                NotEdited oldValue

            False ->
                Edited oldValue newValue

changeEditedValue2 : Editable a -> Editable a -> Editable a
changeEditedValue2 eOldValue eNewValue =
    let
        oldValue = notEditedValue eOldValue
        newValue = editedOrNotEditedValue eNewValue
    in
        case oldValue == newValue of
        True ->
            NotEdited oldValue

        False->
            eNewValue
