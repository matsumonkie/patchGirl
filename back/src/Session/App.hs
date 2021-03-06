{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# OPTIONS_GHC -fno-warn-unused-binds #-}
{-# OPTIONS_GHC -fno-warn-deprecations #-}

module Session.App where


import           Account.Model
import           Control.Monad.Except                (MonadError)
import           Control.Monad.IO.Class              (MonadIO)
import           Control.Monad.Reader                (MonadReader)
import           Control.Monad.Trans                 (liftIO)
import           Data.Functor                        ((<&>))
import           Data.Maybe                          (listToMaybe)
import           Data.Text                           (Text)
import           Data.Text.Encoding                  (decodeUtf8)
import           Database.PostgreSQL.Simple          (Connection, query)
import           Database.PostgreSQL.Simple.SqlQQ
import           DB
import           Model
import           PatchGirl
import           Servant
import           Servant.API.ResponseHeaders         (noHeader)
import           Servant.Auth.Server                 (AuthResult (..),
                                                      CookieSettings,
                                                      JWTSettings, SetCookie,
                                                      acceptLogin, clearSession,
                                                      makeXsrfCookie)
import           Servant.Auth.Server.SetCookieOrphan ()
import           Servant.Server                      (ServerError)
import           Session.Model
import           Web.Cookie                          (setCookieValue)

-- * who am I


whoAmIHandler
  :: ( MonadReader Config m
     , MonadIO m
     , MonadError ServerError m
     )
  => CookieSettings
  -> JWTSettings
  -> AuthResult CookieSession
  -> m (Headers '[ Header "Set-Cookie" SetCookie
                 , Header "Set-Cookie" SetCookie
                 ]
         Session)
whoAmIHandler cookieSettings jwtSettings = \case
  Authenticated SignedUserCookie {..} -> do
    csrfToken <- liftIO createCsrfToken
    let (CaseInsensitive email) = _cookieAccountEmail
    return $
      noHeader $ noHeader $ SignedUserSession { _sessionAccountId = _cookieAccountId
                                              , _sessionEmail = email
                                              , _sessionCsrfToken = csrfToken
                                              }

  _ -> do
    csrfToken <- liftIO createCsrfToken
    let cookieSession =
          VisitorCookie { _cookieAccountId = 1 }
    mApplyCookies <- liftIO $ acceptLogin cookieSettings jwtSettings cookieSession
    case mApplyCookies of
      Nothing           -> throwError err401
      Just applyCookies -> return $ applyCookies $ VisitorSession { _sessionAccountId = 1
                                                                  , _sessionCsrfToken = csrfToken
                                                                  }
  where
    createCsrfToken :: IO Text
    createCsrfToken = do
      setCookie <- liftIO $ makeXsrfCookie cookieSettings
      return $ (decodeUtf8 . setCookieValue) setCookie


-- * sign in


signInHandler
  :: ( MonadReader Config m
     , MonadIO m
     , MonadError ServerError m
     )
  => CookieSettings
  -> JWTSettings
  -> SignIn
  -> m (Headers '[ Header "Set-Cookie" SetCookie
                 , Header "Set-Cookie" SetCookie]
         Session)
signInHandler cookieSettings jwtSettings login = do
  connection <- getDBConnection
  mAccount <- liftIO $ selectAccount login connection
  case mAccount of
    Nothing ->
      throwError err401

    Just Account {..} -> do
      let CaseInsensitive email = _accountEmail
      let cookieSession =
            SignedUserCookie { _cookieAccountId = _accountId
                             , _cookieAccountEmail = _accountEmail
                             }
      let session =
            SignedUserSession { _sessionAccountId = _accountId
                              , _sessionEmail = email
                              , _sessionCsrfToken = ""
                              }
      mApplyCookies <- liftIO $ acceptLogin cookieSettings jwtSettings cookieSession
      case mApplyCookies of
        Nothing           -> throwError err401
        Just applyCookies -> return $ applyCookies session

selectAccount :: SignIn -> Connection -> IO (Maybe Account)
selectAccount SignIn {..} connection =
  query connection selectAccountQuery (_signInEmail, _signInPassword) <&> listToMaybe
  where
    selectAccountQuery =
      [sql|
          SELECT id, email
          FROM account
          WHERE email = ?
          AND password = crypt(?, password);
          |]


-- * sign out


deleteSessionHandler
  :: ( MonadReader Config m
     , MonadIO m
     , MonadError ServerError m
     )
  => CookieSettings
  -> m (Headers '[ Header "Set-Cookie" SetCookie
                 , Header "Set-Cookie" SetCookie
                 ]
         Session)
deleteSessionHandler cookieSettings =
  return $
    clearSession cookieSettings $ VisitorSession { _sessionAccountId = 1
                                                 , _sessionCsrfToken = ""
                                                 }
