## master

- Removed support for Carthage.
- Removed support for Cocoapods
- Rewritten from scratch to support TOML 1.0
- Remove dependency on NetTime, parser returns `Foundation.Date` and
  `Foundation.DateComponents` instead.
- Improved error reporting: a parsing error won't cause parsing to stop.
  Instead, the parser will attempt to parse as much as possible and report all
  errors it encounters.

## 0.2.5

- Fixed @rpath for dynamic framework support (Carthage, etc).
