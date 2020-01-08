{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveAnyClass             #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE DuplicateRecordFields      #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase                 #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE NamedFieldPuns             #-}
{-# LANGUAGE NoMonomorphismRestriction  #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE TypeOperators              #-}

module Session.AppSpec where

import           App
import           Control.Monad.Except   (MonadError)
import           Control.Monad.IO.Class (MonadIO)
import           Control.Monad.Reader   (MonadReader)
import           Data.Functor           ((<&>))
import           Helper.App
import           Helper.DB              (cleanDBAfter)
import           PatchGirl
import           Servant
import           Servant                (Header, Headers, Proxy, err400)
import           Servant.Auth.Server    (CookieSettings, JWTSettings, SetCookie)
import           Servant.Client
import           Servant.Server         (ServerError)
import           Session.Model
import           Test.Hspec


-- * client


signOut :: ClientM (Headers '[ Header "Set-Cookie" SetCookie
                             , Header "Set-Cookie" SetCookie]
                     Session)
signin :<|> signup :<|> signOut =
  client (Proxy :: Proxy LoginApi)


-- * spec


spec :: Spec
spec = do
  describe "sign out" $ do
    withClient (mkApp defaultConfig) $ do
      it "always return a visitor session and clean the cookies" $ \clientEnv ->
        cleanDBAfter $ \connection -> do
          ([(headerName, headerValue), _], session) <- try clientEnv signOut <&> (\r -> (getHeaders r, getResponse r))
          headerName `shouldBe` "Set-Cookie"
          headerValue `shouldBe` "JWT=value; Path=/; Expires=Tue, 10-Oct-1995 00:00:00 GMT; Max-Age=0; HttpOnly; Secure"
          session `shouldBe` VisitorSession { _sessionAccountId = 1
                                            , _sessionCsrfToken = ""
                                            }
