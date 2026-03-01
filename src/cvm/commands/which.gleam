/// Print the path to the active caffeine binary.

import cvm/env

/// Return the filesystem path to the active caffeine binary.
pub fn run() -> Result(String, String) {
  case env.current_version() {
    "" -> Error("no active version (run: cvm use <version>)")
    _ -> Ok(env.current_link() <> "/caffeine")
  }
}
