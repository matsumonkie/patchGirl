{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE RecordWildCards   #-}


module RequestCollection.Sql where

import           Database.PostgreSQL.Simple
import           Database.PostgreSQL.Simple.SqlQQ
import           RequestCollection.Model
import           RequestNode.Model


-- * DB


selectRequestCollectionAvailable :: Int -> Int -> Connection -> IO Bool
selectRequestCollectionAvailable accountId requestCollectionId connection =
  query connection collectionExistsSql (requestCollectionId, accountId) >>= \case
    [Only True] -> return True
    _ -> return False
  where
    collectionExistsSql =
      [sql|
          SELECT EXISTS (
            SELECT 1
            FROM request_collection
            WHERE id = ?
            AND account_id = ?
          );
          |]

selectRequestCollectionById :: Int -> Connection -> IO (Maybe RequestCollection)
selectRequestCollectionById requestCollectionId connection = do
    [(_, mRequestNodesFromPG)] <- query connection selectRequestCollectionSql (Only requestCollectionId) :: IO[(Int, Maybe [RequestNodeFromPG])]
    case mRequestNodesFromPG of
      Just requestNodesFromPG ->
        return . Just $ RequestCollection requestCollectionId (fromPgRequestNodeToRequestNode <$> requestNodesFromPG)
      Nothing ->
        return . Just $ RequestCollection requestCollectionId []
  where
    selectRequestCollectionSql =
      [sql|
          SELECT 1, *
          FROM request_nodes_as_json(?)
          |] :: Query
