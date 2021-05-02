# Copyright: (c) 2021 Monocle authors
# SPDX-License-Identifier: AGPL-3.0-only

import grpc
# Generated fri client with grpc_tools
import fri.messages_pb2 as Fri
import fri.services_pb2_grpc as FriClient


def run():
    with grpc.insecure_channel('127.0.0.1:8042') as channel:
        print("Starting request", channel)
        stub = FriClient.ServiceStub(channel)
        req = Fri.RegisterRequest(username='TristanCacqueray')
        for resp in stub.Register(req):
            print(resp)
    print("Done.")


if __name__ == '__main__':
    run()
