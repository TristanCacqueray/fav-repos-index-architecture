type client
@module("./fri_grpc_web_pb.js") @new external newServiceClient: string => client = "ServiceClient"

type registerRequest
@module("./fri_pb.js") @new
external newRegisterRequest: string => registerRequest = "RegisterRequest"

type stream
let register: (client, registerRequest) => stream = %raw(`

  function(client, request) {
    console.log("Setting register stream...");
    const stream = client.register(request, {});
    return stream;
  }
`)
