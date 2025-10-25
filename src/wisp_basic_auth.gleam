import gleam/bit_array
import gleam/http/request
import gleam/list

import wisp

// Tuple of client id and password
pub type ClientAuth =
  #(String, String)

pub fn validate_basic_auth(
  request: wisp.Request,
  known_clients: List(ClientAuth),
  realm: String,
  handler: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  case request.get_header(request, "Authorization") {
    Error(_) -> unauthorized_response(realm)
    Ok(auth_header) -> {
      case check_authorization(auth_header, known_clients) {
        Ok(_) -> handler(request)
        Error(Nil) -> wisp.response(403)
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
