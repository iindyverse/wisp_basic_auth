# wisp_basic_auth

Wisp middleware of the [Basic Authentication Scheme](basicaa).

> The basic authentication scheme is a non-secure method of filtering unauthorized access to resources on an HTTP server. It is based on the assumption that the connection between the client and the server can be regarded as a trusted carrier. As this is not generally true on an open network, the basic authentication scheme should be used accordingly.

[![Package Version](https://img.shields.io/hexpm/v/wisp_basic_auth)](https://hex.pm/packages/wisp_basic_auth)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/wisp_basic_auth/)

```sh
gleam add wisp_basic_auth@1
```

Append the middleware in your router:

```gleam
import wisp_basic_auth

const realm = "Secure"
const known_clients = [#("Aladdin", "open sesame")]

use request <- validate_basic_auth(realm, known_clients)

```

Further documentation can be found at <https://hexdocs.pm/wisp_basic_auth>.

## Development

```sh
gleam test
```

[basicaa]: https://www.w3.org/Protocols/HTTP/1.0/spec.html#BasicAA