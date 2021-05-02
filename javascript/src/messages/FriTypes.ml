[@@@ocaml.warning "-27-30-39"]


type repo = {
  name : string;
  topic : string list;
  description : string;
  stargazers : string list;
}

type register_request = {
  username : string;
}

type register_response =
  | Repo of repo
  | Msg of string

type search_request = {
  query : string;
}

type search_response = {
  score : int32;
  repo : repo option;
}

let rec default_repo 
  ?name:((name:string) = "")
  ?topic:((topic:string list) = [])
  ?description:((description:string) = "")
  ?stargazers:((stargazers:string list) = [])
  () : repo  = {
  name;
  topic;
  description;
  stargazers;
}

let rec default_register_request 
  ?username:((username:string) = "")
  () : register_request  = {
  username;
}

let rec default_register_response () : register_response = Repo (default_repo ())

let rec default_search_request 
  ?query:((query:string) = "")
  () : search_request  = {
  query;
}

let rec default_search_response 
  ?score:((score:int32) = 0l)
  ?repo:((repo:repo option) = None)
  () : search_response  = {
  score;
  repo;
}
