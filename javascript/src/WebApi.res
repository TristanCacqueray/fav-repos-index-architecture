// Note: this does not work as expected, grpc-web js library needs more work for rescript interop:
//   it's missing a fromObject constructor
//   the toObject result is different from protobuf json decoder
//   stream response may not be the best fit too
//
// Todo: investigate either
//   https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_filters/grpc_json_transcoder_filter
//   https://github.com/grpc-ecosystem/grpc-gateway
//
type client
@module("./fri/services_grpc_web_pb.js") @new
external newServiceClient: string => client = "ServiceClient"

// TODO: properly bind grpc-web object creation
type registerRequest
@module("./fri/messages_pb.js") @new
external newRegisterRequest: unit => 'a = "RegisterRequest"
let registerRequest: string => registerRequest = %raw(`
  function (value) {
    const req = newRegisterRequest();
    req.setUsername(value);
    return req;
  }
`)

type searchRequest
@module("./fri/messages_pb.js") @new
external newSearchRequest: unit => 'obj = "SearchRequest"
let searchRequest: string => searchRequest = %raw(`
  function (value) {
    const req = newSearchRequest();
    req.setQuery(value);
    return req;
  }
`)

module FriTypes = MessagesTypes
module FriBs = MessagesBs

type registerResponseRaw = {
  msg: string,
  repo: Js.Nullable.t<Js.Dict.t<Js.Json.t>>,
}
let decodeRegisterResp = (raw: registerResponseRaw): FriTypes.register_response =>
  switch (raw.msg, raw.repo->Js.Nullable.toOption) {
  | ("", Some(repo)) => repo->FriBs.decode_repo->FriTypes.Repo
  | (msg, None) => msg->FriTypes.Msg
  }

type stream
let register: (client, registerRequest, FriTypes.register_response => unit) => stream = %raw(`
  function(client, request, data_cb) {
    console.log("Setting register stream...", request.toObject());
    const stream = client.register(request, {});
    stream.on("data", data => {
      const obj = data.toObject()
      console.log("onData:", obj)
      data_cb(decodeRegisterResp(obj));
    });
    stream.on("status", status => console.log("onStatus:", status));
    stream.on("error", error => console.log("onError:", error));
    return stream;
  }
`)

let decodeSearchResp: Js.Dict.t<
  Js.Json.t,
> => FriTypes.search_response = FriBs.decode_search_response

let search: (client, searchRequest, FriTypes.search_response => unit) => stream = %raw(`
  function(client, request, data_cb) {
    console.log("Setting search stream...", request.toObject());
    const stream = client.search(request, {});
    stream.on("data", data => {
      const obj = data.toObject()
      console.log("onSearchData:", obj)
      data_cb(decodeSearchResp(obj));
    });
    stream.on("status", status => console.log("onSearchStatus:", status));
    stream.on("error", error => console.log("onSearchError:", error));
    return stream;
  }
`)
