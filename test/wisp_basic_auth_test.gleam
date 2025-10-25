import gleam/http
import gleam/http/response.{Response}
import gleam/list
import gleeunit
import wisp
import wisp/simulate
import wisp_basic_auth

const realm = "Secure"

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn without_authorized_header_returns_401_test() {
  let req = simulate.request(http.Get, "")
  let assert Response(401, headers, wisp.Text("Unauthorized")) =
    wisp_basic_auth.validate_basic_auth(req, realm, [], success_handler)

  assert Ok("Basic realm=\"" <> realm <> "\"")
    == list.key_find(headers, "www-authenticate")
}

pub fn with_authorized_header_returns_403_test() {
  let req = request_with_auth()

  let assert Response(403, [], wisp.Text("Forbidden")) =
    wisp_basic_auth.validate_basic_auth(req, realm, [], success_handler)
}

pub fn with_authorized_header_and_known_id_test() {
  let req = request_with_auth()
  let known_clients = [#("Aladdin", "open sesame")]

  let assert Response(204, [], wisp.Text("")) =
    wisp_basic_auth.validate_basic_auth(
      req,
      realm,
      known_clients,
      success_handler,
    )
}

fn success_handler(_request) {
  wisp.response(204)
}

fn request_with_auth() {
  http.Get
  |> simulate.request("")
  |> simulate.header("Authorization", "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==")
}
