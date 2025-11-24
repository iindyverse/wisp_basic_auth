# wisp_basic_auth

[Wisp][wisp] middleware of the HTTP [Basic Authentication Scheme][basicaa].

> The basic authentication scheme is a non-secure method of filtering unauthorized access to resources on an HTTP server. It is based on the assumption that the connection between the client and the server can be regarded as a trusted carrier. As this is not generally true on an open network, the basic authentication scheme should be used accordingly.

## Timing attacks

Please note this implementation is vulnerable to [Timing Attacks][ta] if used without some kind of rate limiting protection. 

For proper protection of your assets consider [OAuth][oa]. If you must use this library
protect your endpoints with rate limiting and perhaps a middleware that detects unauthorized
responses and forces the client to wait before receiving the error code.

[![Package Version](https://img.shields.io/hexpm/v/wisp_basic_auth)](https://hex.pm/packages/wisp_basic_auth)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/wisp_basic_auth/)

```sh
gleam add wisp_basic_auth@1
```

Prepend the middleware in your handler or router:

```gleam
import wisp_basic_auth.{validate_basic_auth}

const realm = "Secure"
const known_clients = [#("Aladdin", "open sesame")]

pub fn handle_request(request: Request) -> Response {
  let validate_basic_auth = validate_basic_auth(realm, known_clients)
  use request <- validate_basic_auth(realm, known_clients)
  wisp.ok()
}
```

Note due to the use of a closure and the requirements of the [Gleam use][use]
expression two steps are needed to add the middleware.

## Development

```sh
gleam test
```

[basicaa]: https://www.w3.org/Protocols/HTTP/1.0/spec.html#BasicAA
[oa]: https://en.wikipedia.org/wiki/OAuth
[ta]: https://en.wikipedia.org/wiki/Timing_attack
[use]: https://tour.gleam.run/advanced-features/use/
[wisp]: https://hex.pm/packages/wisp