/// Print the current active caffeine version.

import cvm/env

/// Return the currently active version string.
pub fn run() -> Result(String, String) {
  case env.current_version() {
    "" -> Error("no active version (run: cvm use <version>)")
    v -> Ok("v" <> v)
  }
}
