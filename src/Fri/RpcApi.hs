{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE NoImplicitPrelude #-}

-- | Protobuf implementation layer
module Fri.RpcApi (runService) where

import Fri.Messages
import Fri.Services
import Fri.Types
import Network.GRPC.HighLevel.Generated
import Relude

registerHandler ::
  RegisterImpl IO ->
  ServerRequest 'ServerStreaming RegisterRequest RegisterResponse ->
  IO (ServerResponse 'ServerStreaming RegisterResponse)
registerHandler registerImpl (ServerWriterRequest _metadata (RegisterRequest username) sendResponse) = do
  putTextLn $ "GRPC: got user request: " <> toStrict username
  registerImpl (UserName $ toStrict username) cb
  pure (ServerWriterResponse mempty StatusOk (StatusDetails "ok"))
  where
    cb res = do
      let value = case res of
            Left msg -> RegisterResponseValueMsg . toLazy $ msg
            Right repo -> RegisterResponseValueRepo $ repo
      resp <- sendResponse (RegisterResponse . Just $ value)

      print resp

searchHandler ::
  SearchImpl IO ->
  ServerRequest 'ServerStreaming SearchRequest SearchResponse ->
  IO (ServerResponse 'ServerStreaming SearchResponse)
searchHandler registerImpl (ServerWriterRequest _metadata (SearchRequest txt) sendResponse) = do
  putTextLn $ "GRPC: got search request: " <> toStrict txt
  registerImpl (toStrict txt) cb
  pure (ServerWriterResponse mempty StatusOk (StatusDetails "ok"))
  where
    cb res = do
      resp <- sendResponse (SearchResponse 42 (Just res))

      print resp

runService :: Int -> RegisterImpl IO -> SearchImpl IO -> IO ()
runService port registerImpl searchImpl = do
  serviceServer handlers (options {serverPort = Port port})
  where
    handlers :: Service ServerRequest ServerResponse
    handlers =
      Service
        { serviceRegister = registerHandler registerImpl,
          serviceSearch = searchHandler searchImpl
        }
    options :: ServiceOptions
    options = defaultServiceOptions
