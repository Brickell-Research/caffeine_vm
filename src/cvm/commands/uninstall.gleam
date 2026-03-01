/// Remove an installed caffeine version.

import cvm/env
import cvm/output
import gleam/bool
import gleam/result
import simplifile

/// Uninstall a caffeine version by removing its directory.
pub fn run(version: String) -> Result(String, String) {
  let version = env.strip_v(version)
  use <- bool.guard(
    !env.is_installed(version),
    Error("v" <> version <> " is not installed"),
  )

  // Clear the active symlink if removing the current version
  use <- bool.lazy_guard(version == env.current_version(), fn() {
    let _ = simplifile.delete(env.current_link())
    output.warn(
      "v" <> version <> " was the active version — no version is now active",
    )
    do_delete(version)
  })

  do_delete(version)
}

fn do_delete(version: String) -> Result(String, String) {
  simplifile.delete(env.version_dir(version))
  |> result.map(fn(_) { "uninstalled caffeine v" <> version })
  |> result.map_error(fn(_) { "failed to remove v" <> version })
}
