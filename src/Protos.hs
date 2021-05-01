{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE NoImplicitPrelude #-}

-- | Protobuf implementation layer
module Protos (runService) where

import Fri.Types
import Network.GRPC.HighLevel.Generated
import Protos.Fri
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

runService :: Int -> RegisterImpl IO -> IO ()
runService port registerImpl = do
  serviceServer handlers (options {serverPort = Port port})
  where
    handlers :: Service ServerRequest ServerResponse
    handlers =
      Service
        { serviceRegister = registerHandler registerImpl,
          serviceSearch = undefined
        }
    options :: ServiceOptions
    options = defaultServiceOptions
