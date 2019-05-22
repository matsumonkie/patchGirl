module EnvApp.App exposing (..)

import EnvApp.Model exposing (..)
import EnvApp.Message exposing (Msg(..))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PromptKey idx str ->
      (modify (changeKey str) idx model, Cmd.none)

    PromptValue idx str ->
      (modify (changeValue str) idx model, Cmd.none)

    AddNewInput ->
      (model ++ emptyModel, Cmd.none)

    DeleteInput idx ->
      (delete idx model, Cmd.none)

changeKey : String -> KeyValue -> KeyValue
changeKey newKey model =
  (newKey, Tuple.second model)

changeValue : String -> KeyValue -> KeyValue
changeValue newValue model =
  (Tuple.first model, newValue)

modify : (KeyValue -> KeyValue) -> Int -> Model -> Model
modify f idx elems =
  case (idx, elems) of
    (0, elem :: tail) -> f elem :: tail
    (_, []) -> elems
    (_, elem :: tail) -> elem :: (modify f (idx - 1) tail)

delete : Int -> Model -> Model
delete idx model =
  case (idx, model) of
    (0, elem :: tail) -> tail
    (_, []) -> model
    (_, elem :: tail) -> elem :: (delete (idx - 1) tail)