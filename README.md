# TOMLDeserializer

Turn TOML data into Swift objects.

```swift
try TOMLDeserializer.tomlTable(with: data) // [String: Any]
```

Compatible with [TOML v0.5.0][]

Unless you have a good reason not to, [TOMLDecoder][] is probably a better choice for your TOML needs.

[TOML v0.5.0]: https://github.com/toml-lang/toml/blob/master/versions/en/toml-v0.5.0.md
[TOMLDecoder]: https://github.com/dduan/TOMLDecoder

## Installation

#### With [CocoaPods](http://cocoapods.org/)

```ruby
use_frameworks!

pod "TOMLDeserializer"
```

#### With [SwiftPM](https://swift.org/package-manager)

```swift
.package(url: "https://github.com/dduan/TOMLDeserializer", from: "0.1.3")
```

#### With [Carthage](https://github.com/Carthage/Carthage)

```
github "dduan/TOMLDeserializer"
```

## Types

In addition to Swift types from the standard library, date and time are
represeted with types from the [NetTime][] library. The following is a mapping
from types defined in the TOML spec to Swift types.

| TOML             | Swift                   |
| -                | -                       |
| String           | `Swift.String`          |
| Integer          | `Swift.Int64`           |
| Float            | `Swift.Double`          |
| Boolean          | `Swift.Bool`            |
| Local Time       | `NetTime.LocalTime`     |
| Local Date       | `NetTime.LocalDate`     |
| Local Date-Time  | `NetTime.LocalDateTime` |
| Offset Date-Time | `NetTime.DateTime`      |
| Array            | `Swift.[Any]`           |
| Table            | `Swift.[String: Any]`   |

[NetTime]: https://github.com/dduan/NetTime

## License

MIT. See `LICENSE.md`.
