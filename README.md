# wisp_basic_auth

Wisp middleware of the [Basic Authentication Scheme][basicaa].

> The basic authentication scheme is a non-secure method of filtering unauthorized access to resources on an HTTP server. It is based on the assumption that the connection between the client and the server can be regarded as a trusted carrier. As this is not generally true on an open network, the basic authentication scheme should be used accordingly.

[![Package Version](https://img.shields.io/hexpm/v/wisp_basic_auth)](https://hex.pm/packages/wisp_basic_auth)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/wisp_basic_auth/)

```sh
gleam add wisp_basic_auth@1
```
```gleam
import wisp_basic_auth

pub fn main() -> Nil {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://hexdocs.pm/wisp_basic_auth>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

[basicaa][https://www.w3.org/Protocols/HTTP/1.0/spec.html#BasicAA]