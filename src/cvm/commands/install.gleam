/// Install a caffeine version.

import cvm/commands/switch
import cvm/env
import cvm/github
import cvm/output
import gleam/bool
import gleam/result
import shellout
import simplifile

/// Install a caffeine version.
/// Pass "latest" to resolve automatically, or "" to read from .caffeine-version.
pub fn run(version: String) -> Result(String, String) {
  use version <- result.try(resolve_version(version))

  use <- bool.lazy_guard(env.is_installed(version), fn() {
    output.ok("v" <> version <> " is already installed")
    switch.run(version)
  })

  do_install(version)
}

fn resolve_version(version: String) -> Result(String, String) {
  case version {
    "" -> resolve_from_file()
    "latest" -> {
      output.info("resolving latest version...")
      github.resolve_latest()
    }
    v -> Ok(env.strip_v(v))
  }
}

fn resolve_from_file() -> Result(String, String) {
  env.read_version_file()
  |> result.map(fn(v) {
    output.info("using version " <> v <> " from .caffeine-version")
    v
  })
  |> result.map_error(fn(_) {
    "usage: cvm install <version>  (or create a .caffeine-version file)"
  })
}

fn do_install(version: String) -> Result(String, String) {
  use plat <- result.try(env.detect_platform())

  let _ = simplifile.create_directory_all(env.versions_dir())

  let url = github.download_url(version, plat)
  output.info("installing caffeine v" <> version <> " (" <> plat <> ")")

  let tmpdir = "/tmp/cvm-install"
  let archive = tmpdir <> "/caffeine.tar.gz"
  let extract_dir = tmpdir <> "/extract"
  let _ = simplifile.delete(tmpdir)
  let _ = simplifile.create_directory_all(extract_dir)

  use _ <- result.try(
    github.download(url, to: archive)
    |> result.map_error(fn(_) {
      "download failed — check that v" <> version <> " exists"
    }),
  )

  use _ <- result.try(
    shellout.command(
      run: "tar",
      with: ["-xzf", archive, "-C", extract_dir],
      in: ".",
      opt: [],
    )
    |> result.map_error(fn(e) { "extract failed: " <> e.1 }),
  )

  use source <- result.try(find_extracted_dir(extract_dir, version, plat))

  let dest = env.version_dir(version)
  let _ = simplifile.create_directory_all(dest)

  // Copy entire release directory (ERTS + libs + wrapper script)
  use _ <- result.try(
    shellout.command(
      run: "cp",
      with: ["-r", source <> "/.", dest],
      in: ".",
      opt: [],
    )
    |> result.map_error(fn(e) { "copy failed: " <> e.1 }),
  )

  use _ <- result.try(
    shellout.command(
      run: "chmod",
      with: ["+x", env.caffeine_binary(version)],
      in: ".",
      opt: [],
    )
    |> result.map_error(fn(e) { "chmod failed: " <> e.1 }),
  )

  let _ = simplifile.delete(tmpdir)

  output.ok("installed caffeine v" <> version)
  switch.run(version)
}

/// Locate the extracted release directory in the archive output.
/// The tarball extracts to a directory named `caffeine-{version}-{platform}/`.
fn find_extracted_dir(
  dir: String,
  version: String,
  platform: String,
) -> Result(String, String) {
  let path = dir <> "/caffeine-" <> version <> "-" <> platform

  case simplifile.is_directory(path) |> result.unwrap(False) {
    True -> Ok(path)
    False -> Error("could not find caffeine release directory in archive")
  }
}
