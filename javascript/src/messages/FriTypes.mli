(** fri.proto Types *)



(** {2 Types} *)

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


(** {2 Default values} *)

val default_repo : 
  ?name:string ->
  ?topic:string list ->
  ?description:string ->
  ?stargazers:string list ->
  unit ->
  repo
(** [default_repo ()] is the default value for type [repo] *)

val default_register_request : 
  ?username:string ->
  unit ->
  register_request
(** [default_register_request ()] is the default value for type [register_request] *)

val default_register_response : unit -> register_response
(** [default_register_response ()] is the default value for type [register_response] *)

val default_search_request : 
  ?query:string ->
  unit ->
  search_request
(** [default_search_request ()] is the default value for type [search_request] *)

val default_search_response : 
  ?score:int32 ->
  ?repo:repo option ->
  unit ->
  search_response
(** [default_search_response ()] is the default value for type [search_response] *)
