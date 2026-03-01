/// Switch active caffeine version.
import cvm/env
import gleam/bool
import gleam/result
import simplifile

/// Switch active version by updating the current symlink.
pub fn run(version: String) -> Result(String, String) {
  let version = env.strip_v(version)
  use <- bool.guard(
    !env.is_installed(version),
    Error(
      "v" <> version <> " is not installed (run: cvm install " <> version <> ")",
    ),
  )

  let link = env.current_link()
  let _ = simplifile.delete(link)
  simplifile.create_symlink(env.version_dir(version), link)
  |> result.map(fn(_) { "now using caffeine v" <> version })
  |> result.map_error(fn(_) { "failed to create symlink" })
}
