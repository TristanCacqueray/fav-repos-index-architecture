{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE NoImplicitPrelude #-}

module GRPC.Api (run) where

import Network.GRPC.HighLevel.Generated
import qualified Protos.Fri as FriProto
import Relude

handlers :: FriProto.Service ServerRequest ServerResponse
handlers = FriProto.Service {FriProto.serviceRegister = registerHandler}

registerHandler ::
  ServerRequest 'ServerStreaming FriProto.RegisterRequest FriProto.RegisterResponse ->
  IO (ServerResponse 'ServerStreaming FriProto.RegisterResponse)
registerHandler (ServerWriterRequest _metadata (FriProto.RegisterRequest username) sendResponse) = do
  putTextLn $ "Registering user: " <> toStrict username
  res <- go fakeRepos
  print res
  putTextLn "over!"
  pure (ServerWriterResponse mempty StatusOk (StatusDetails "ok"))
  where
    fakeRepos = [FriProto.Repo "testy" "haskell" "a test project", FriProto.Repo "testo" "rescript" "a test client"]
    go [] = sendResponse (FriProto.RegisterResponse 1 (Just $ FriProto.RegisterResponseValueMsg "ok"))
    go (x : xs) = do
      res <- sendResponse (FriProto.RegisterResponse 1 (Just $ FriProto.RegisterResponseValueRepo x))
      print res
      go xs

options :: ServiceOptions
options = defaultServiceOptions {useCompression = True, initialMetadata = [("hi", "hi")]}

run :: Int -> IO ()
run port = do
  FriProto.serviceServer handlers (options {serverPort = Port port})
