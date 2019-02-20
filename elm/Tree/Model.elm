module Tree.Model exposing (..)

import Builder.Model as Builder

type alias Folder2 =
  { name : String
  , open : Bool
  , showRenameInput : Bool
  , children : Tree
  }

type alias File2 =
  { name : String
  , showRenameInput : Bool
  , builder : Builder.Model
  }

type Node = Folder Folder2 | File File2

type alias Tree = List(Node)

type alias Model =
  { selectedNode : Maybe Node
  , displayedBuilderIndexes : List(Int)
  , tree : Tree
  }

defaultFolder =
  Folder { name = "new folder"
         , open = False
         , children = []
         , showRenameInput = False
         }

defaultFile =
  File { name = "new file"
       , builder = Builder.defaultBuilder
       , showRenameInput = False
       }

defaultTree =
  [ Folder { name = "folder1"
           , open = False
           , children = []
           , showRenameInput = False
           }
  , Folder { name = "folder2"
           , open = True
           , showRenameInput = False
           , children = [ Folder { name = "folder2.2"
                                 , open = True
                                 , children = []
                                 , showRenameInput = False
                                 }
                        , Folder { name = "folder3"
                                 , open = True
                                 , showRenameInput = False
                                 , children = [ File { name = "file1"
                                                     , builder = Builder.defaultModel1
                                                     , showRenameInput = False
                                                     }
                                              , File { name = "file2"
                                                     , builder = Builder.defaultModel2
                                                     , showRenameInput = False
                                                     }
                                              ]
                                 }
                        ]
           }
  ]
