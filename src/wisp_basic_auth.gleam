import gleam/bit_array
import gleam/http/request
import gleam/list

import wisp

// Tuple of client id and password
pub type ClientAuth =
  #(String, String)

/// Middleware that validates an `Authorization: Basic` header
/// against a known list of client ids and passwords within a realm.
/// 
/// The basic authentication scheme is based on the model that the 
/// user agent must authenticate itself with a user-ID and a password 
/// for each realm.
/// 
/// The realm value should be considered an opaque string which can 
/// only be compared for equality with other realms on that server.
/// 
/// Example header: `Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==`
/// 
/// ```gleam
/// use request <- validate_basic_auth("Agrabah", [#("Aladdin", "open sesame")])
/// ```
pub fn validate_basic_auth(
  request: wisp.Request,
  realm: String,
  known_clients: List(ClientAuth),
  handler: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  case request.get_header(request, "Authorization") {
    Error(_) -> unauthorized_response(realm)
    Ok(auth_header) -> {
      case check_authorization(auth_header, known_clients) {
        Ok(_) -> handler(request)
        Error(Nil) -> forbidden_response()
      }
    }
  }
}

fn check_authorization(
  authorization_header: String,
  authorized: List(ClientAuth),
) {
  let match = fn(auth) {
    let #(id, password) = auth
    case encode_creds(id, password) == authorization_header {
      True -> Ok(id)
      False -> Error(Nil)
    }
  }
  list.find_map(authorized, match)
}

fn encode_creds(id, secret) -> String {
  let expected_creds = id <> ":" <> secret
  let encoded_creds =
    bit_array.base64_encode(bit_array.from_string(expected_creds), True)
  "Basic " <> encoded_creds
}

fn unauthorized_response(realm: String) {
  let realm = "Basic realm=\"" <> realm <> "\""
  401
  |> wisp.response()
  |> wisp.string_body("Unauthorized")
  |> wisp.set_header("WWW-Authenticate", realm)
}

fn forbidden_response() {
  403 |> wisp.response() |> wisp.string_body("Forbidden")
}
