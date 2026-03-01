/// List installed and remote caffeine versions.

import cvm/env
import cvm/github
import cvm/output
import gleam/bool
import gleam/list
import gleam/result
import gleam/string
import simplifile

/// List installed versions, marking the current one.
pub fn run() -> Result(String, String) {
  let _ = simplifile.create_directory_all(env.versions_dir())
  let cur = env.current_version()

  let entries =
    simplifile.read_directory(env.versions_dir()) |> result.unwrap([])
  let versions = list.sort(entries, string.compare)

  use <- bool.guard(
    list.is_empty(versions),
    Ok("  no versions installed\n  run: cvm install latest"),
  )

  Ok(
    versions
    |> list.map(fn(v) { format_version(v, v == cur, False) })
    |> string.join("\n"),
  )
}

/// List versions available on GitHub.
pub fn remote() -> Result(String, String) {
  output.info("fetching releases...")
  use releases <- result.try(github.list_releases())
  let cur = env.current_version()

  Ok(
    releases
    |> list.map(fn(v) { format_version(v, v == cur, env.is_installed(v)) })
    |> string.join("\n"),
  )
}

fn format_version(
  v: String,
  is_current: Bool,
  is_installed: Bool,
) -> String {
  case is_current, is_installed {
    True, _ -> "  * " <> v <> " (current)"
    _, True -> "    " <> v <> " (installed)"
    _, _ -> "    " <> v
  }
}
