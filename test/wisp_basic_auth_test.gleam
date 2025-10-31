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

pub fn with_incorrect_password_test() {
  let req = request_with_auth()
  let known_clients = [#("Aladdin", "pass1234")]

  let assert Response(403, [], wisp.Text("Forbidden")) =
    wisp_basic_auth.validate_basic_auth(
      req,
      realm,
      known_clients,
      success_handler,
    )
}

pub fn with_incorrect_user_test() {
  let req = request_with_auth()
  let known_clients = [#("Jaffar", "open sesame")]

  let assert Response(403, [], wisp.Text("Forbidden")) =
    wisp_basic_auth.validate_basic_auth(
      req,
      realm,
      known_clients,
      success_handler,
    )
}

pub fn parse_credentials_empty_test() {
  assert [] == wisp_basic_auth.parse_credentials("")
}

pub fn parse_credentials_one_test() {
  assert [#("a", "A")] == wisp_basic_auth.parse_credentials("a:A")
}

pub fn parse_credentials_many_test() {
  assert [#("a", "A"), #("b", "B")]
    == wisp_basic_auth.parse_credentials("a:A;b:B")
}

pub fn parse_credentials_robust_test() {
  assert [#("a", "A"), #("b", "B"), #("d", "D")]
    == wisp_basic_auth.parse_credentials("a:A;b:B;c;d:D")
}

fn success_handler(_request) {
  wisp.response(204)
}

fn request_with_auth() {
  http.Get
  |> simulate.request("")
  |> simulate.header("Authorization", "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==")
}
