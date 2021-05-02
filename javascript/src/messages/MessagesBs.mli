(** messages.proto BuckleScript Encoding *)


(** {2 Protobuf JSON Encoding} *)

val encode_repo : MessagesTypes.repo -> Js.Json.t Js.Dict.t
(** [encode_repo v dict] encodes [v] int the given JSON [dict] *)

val encode_register_request : MessagesTypes.register_request -> Js.Json.t Js.Dict.t
(** [encode_register_request v dict] encodes [v] int the given JSON [dict] *)

val encode_register_response : MessagesTypes.register_response -> Js.Json.t Js.Dict.t
(** [encode_register_response v dict] encodes [v] int the given JSON [dict] *)

val encode_search_request : MessagesTypes.search_request -> Js.Json.t Js.Dict.t
(** [encode_search_request v dict] encodes [v] int the given JSON [dict] *)

val encode_search_response : MessagesTypes.search_response -> Js.Json.t Js.Dict.t
(** [encode_search_response v dict] encodes [v] int the given JSON [dict] *)


(** {2 BS Decoding} *)

val decode_repo : Js.Json.t Js.Dict.t -> MessagesTypes.repo
(** [decode_repo decoder] decodes a [repo] value from [decoder] *)

val decode_register_request : Js.Json.t Js.Dict.t -> MessagesTypes.register_request
(** [decode_register_request decoder] decodes a [register_request] value from [decoder] *)

val decode_register_response : Js.Json.t Js.Dict.t -> MessagesTypes.register_response
(** [decode_register_response decoder] decodes a [register_response] value from [decoder] *)

val decode_search_request : Js.Json.t Js.Dict.t -> MessagesTypes.search_request
(** [decode_search_request decoder] decodes a [search_request] value from [decoder] *)

val decode_search_response : Js.Json.t Js.Dict.t -> MessagesTypes.search_response
(** [decode_search_response decoder] decodes a [search_response] value from [decoder] *)
