module Tree.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Tree.Model exposing (Model, Node(..), Tree)
import Tree.Message exposing (Msg(..))
import Tree.FolderView exposing (..)
import Tree.FileView exposing (..)

import Util.View as Util

view : Model -> Html Msg
view model =
  let
    treeView = Tuple.second (nodeView 0 model.displayedNodeMenuIndex model.tree)
  in
    div [ class "columns" ]
      [ div [ class "column is-offset-1" ]
        treeView
      ]

nodeView : Int -> Maybe Int -> Tree -> (Int, List (Html Msg))
nodeView idx mDisplayedNodeMenuIndex tree =
  let
    showMenu = mDisplayedNodeMenuIndex == Just idx
  in
    case tree of
      [] -> (idx, [])
      node :: tail ->
        case node of
          (Folder { name, open, children, showRenameInput }) ->
            let
              (folderIdx, folderChildrenView) = nodeView (idx + 1) mDisplayedNodeMenuIndex children
              (newIdx, tailView) = nodeView folderIdx mDisplayedNodeMenuIndex tail
              currentFolderView = folderView name idx folderChildrenView open showMenu showRenameInput
            in
              (newIdx, currentFolderView :: tailView)

          (File { name, showRenameInput }) ->
            let
              (newIdx, tailView) = nodeView (idx + 1) mDisplayedNodeMenuIndex tail
              currentFileView = fileView name idx showMenu showRenameInput
            in
              (newIdx, currentFileView :: tailView)