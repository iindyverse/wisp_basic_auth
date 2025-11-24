import gleam/bit_array
import gleam/http/request
import gleam/list
import gleam/string

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
/// Using `curl` to set the header:
/// 
/// ```bash
/// curl -X POST -u "client:password" ... https://example.com
/// ```
/// 
/// Set the middleware in your router:
/// 
/// ```gleam
/// let validate_basic_auth = wisp_basic_auth.validate_basic_auth(realm, known_clients)
/// use _ <- validate_basic_auth(request)
/// ```
/// 
pub fn validate_basic_auth(
  realm: String,
  known_clients: List(ClientAuth),
) -> fn(wisp.Request, fn(wisp.Request) -> wisp.Response) -> wisp.Response {
  let authorized_clients = precalculate_credentials(known_clients)

  fn(request, handler) {
    case request.get_header(request, "Authorization") {
      Error(_) -> unauthorized_response(realm)
      Ok(auth_header) -> {
        case list.contains(authorized_clients, auth_header) {
          True -> handler(request)
          False -> forbidden_response()
        }
      }
    }
  }
}

/// Parse a list of credentials in the format `client:password`
/// separated by semi-colons.
/// 
/// ```
/// parse_credentials("a:A;b:B")
/// // -> [#("a", "A"), #("b", "B")]
/// ```
pub fn parse_credentials(credentials: String) -> List(ClientAuth) {
  let split_credential = fn(credential) {
    case string.split_once(credential, on: ":") {
      Ok(credential) -> [credential]
      Error(_) -> []
    }
  }

  credentials
  |> string.split(on: ";")
  |> list.flat_map(split_credential)
}

fn precalculate_credentials(known_clients) {
  list.map(known_clients, fn(id_secret: ClientAuth) {
    encode_creds(id_secret.0, id_secret.1)
  })
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
