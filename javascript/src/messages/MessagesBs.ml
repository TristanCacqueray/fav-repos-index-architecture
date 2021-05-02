[@@@ocaml.warning "-27-30-39"]

type repo_mutable = {
  mutable name : string;
  mutable topic : string list;
  mutable description : string;
  mutable stargazers : string list;
}

let default_repo_mutable () : repo_mutable = {
  name = "";
  topic = [];
  description = "";
  stargazers = [];
}

type register_request_mutable = {
  mutable username : string;
}

let default_register_request_mutable () : register_request_mutable = {
  username = "";
}

type search_request_mutable = {
  mutable query : string;
}

let default_search_request_mutable () : search_request_mutable = {
  query = "";
}

type search_response_mutable = {
  mutable score : int32;
  mutable repo : MessagesTypes.repo option;
}

let default_search_response_mutable () : search_response_mutable = {
  score = 0l;
  repo = None;
}


let rec decode_repo json =
  let v = default_repo_mutable () in
  let keys = Js.Dict.keys json in
  let last_key_index = Array.length keys - 1 in
  for i = 0 to last_key_index do
    match Array.unsafe_get keys i with
    | "name" -> 
      let json = Js.Dict.unsafeGet json "name" in
      v.name <- Pbrt_bs.string json "repo" "name"
    | "topic" -> begin
      let a = 
        let a = Js.Dict.unsafeGet json "topic" in 
        Pbrt_bs.array_ a "repo" "topic"
      in
      v.topic <- Array.map (fun json -> 
        Pbrt_bs.string json "repo" "topic"
      ) a |> Array.to_list;
    end
    | "description" -> 
      let json = Js.Dict.unsafeGet json "description" in
      v.description <- Pbrt_bs.string json "repo" "description"
    | "stargazers" -> begin
      let a = 
        let a = Js.Dict.unsafeGet json "stargazers" in 
        Pbrt_bs.array_ a "repo" "stargazers"
      in
      v.stargazers <- Array.map (fun json -> 
        Pbrt_bs.string json "repo" "stargazers"
      ) a |> Array.to_list;
    end
    
    | _ -> () (*Unknown fields are ignored*)
  done;
  ({
    MessagesTypes.name = v.name;
    MessagesTypes.topic = v.topic;
    MessagesTypes.description = v.description;
    MessagesTypes.stargazers = v.stargazers;
  } : MessagesTypes.repo)

let rec decode_register_request json =
  let v = default_register_request_mutable () in
  let keys = Js.Dict.keys json in
  let last_key_index = Array.length keys - 1 in
  for i = 0 to last_key_index do
    match Array.unsafe_get keys i with
    | "username" -> 
      let json = Js.Dict.unsafeGet json "username" in
      v.username <- Pbrt_bs.string json "register_request" "username"
    
    | _ -> () (*Unknown fields are ignored*)
  done;
  ({
    MessagesTypes.username = v.username;
  } : MessagesTypes.register_request)

let rec decode_register_response json =
  let keys = Js.Dict.keys json in
  let rec loop = function 
    | -1 -> Pbrt_bs.E.malformed_variant "register_response"
    | i -> 
      begin match Array.unsafe_get keys i with
      | "repo" -> 
        let json = Js.Dict.unsafeGet json "repo" in
        (MessagesTypes.Repo ((decode_repo (Pbrt_bs.object_ json "register_response" "Repo"))) : MessagesTypes.register_response)
      | "msg" -> 
        let json = Js.Dict.unsafeGet json "msg" in
        (MessagesTypes.Msg (Pbrt_bs.string json "register_response" "Msg") : MessagesTypes.register_response)
      
      | _ -> loop (i - 1)
      end
  in
  loop (Array.length keys - 1)

let rec decode_search_request json =
  let v = default_search_request_mutable () in
  let keys = Js.Dict.keys json in
  let last_key_index = Array.length keys - 1 in
  for i = 0 to last_key_index do
    match Array.unsafe_get keys i with
    | "query" -> 
      let json = Js.Dict.unsafeGet json "query" in
      v.query <- Pbrt_bs.string json "search_request" "query"
    
    | _ -> () (*Unknown fields are ignored*)
  done;
  ({
    MessagesTypes.query = v.query;
  } : MessagesTypes.search_request)

let rec decode_search_response json =
  let v = default_search_response_mutable () in
  let keys = Js.Dict.keys json in
  let last_key_index = Array.length keys - 1 in
  for i = 0 to last_key_index do
    match Array.unsafe_get keys i with
    | "score" -> 
      let json = Js.Dict.unsafeGet json "score" in
      v.score <- Pbrt_bs.int32 json "search_response" "score"
    | "repo" -> 
      let json = Js.Dict.unsafeGet json "repo" in
      v.repo <- Some ((decode_repo (Pbrt_bs.object_ json "search_response" "repo")))
    
    | _ -> () (*Unknown fields are ignored*)
  done;
  ({
    MessagesTypes.score = v.score;
    MessagesTypes.repo = v.repo;
  } : MessagesTypes.search_response)

let rec encode_repo (v:MessagesTypes.repo) = 
  let json = Js.Dict.empty () in
  Js.Dict.set json "name" (Js.Json.string v.MessagesTypes.name);
  let a = v.MessagesTypes.topic |> Array.of_list |> Array.map Js.Json.string in
  Js.Dict.set json "topic" (Js.Json.array a);
  Js.Dict.set json "description" (Js.Json.string v.MessagesTypes.description);
  let a = v.MessagesTypes.stargazers |> Array.of_list |> Array.map Js.Json.string in
  Js.Dict.set json "stargazers" (Js.Json.array a);
  json

let rec encode_register_request (v:MessagesTypes.register_request) = 
  let json = Js.Dict.empty () in
  Js.Dict.set json "username" (Js.Json.string v.MessagesTypes.username);
  json

let rec encode_register_response (v:MessagesTypes.register_response) = 
  let json = Js.Dict.empty () in
  begin match v with
  | MessagesTypes.Repo v ->
    begin (* repo field *)
      let json' = encode_repo v in
      Js.Dict.set json "repo" (Js.Json.object_ json');
    end;
  | MessagesTypes.Msg v ->
    Js.Dict.set json "msg" (Js.Json.string v);
  end;
  json

let rec encode_search_request (v:MessagesTypes.search_request) = 
  let json = Js.Dict.empty () in
  Js.Dict.set json "query" (Js.Json.string v.MessagesTypes.query);
  json

let rec encode_search_response (v:MessagesTypes.search_response) = 
  let json = Js.Dict.empty () in
  Js.Dict.set json "score" (Js.Json.number (Int32.to_float v.MessagesTypes.score));
  begin match v.MessagesTypes.repo with
  | None -> ()
  | Some v ->
    begin (* repo field *)
      let json' = encode_repo v in
      Js.Dict.set json "repo" (Js.Json.object_ json');
    end;
  end;
  json
