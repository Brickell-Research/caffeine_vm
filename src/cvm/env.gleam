/// Shared helpers — paths, platform detection, version state.
import gleam/bool
import gleam/list
import gleam/result
import gleam/string
import shellout
import simplifile

// --- Paths ---

/// Return the cvm home directory.
pub fn cvm_home() -> String {
  get_env("CVM_HOME")
  |> result.lazy_unwrap(fn() {
    get_env("HOME")
    |> result.map(fn(h) { h <> "/.cvm" })
    |> result.unwrap(".cvm")
  })
}

/// Return the versions directory path.
pub fn versions_dir() -> String {
  cvm_home() <> "/versions"
}

/// Return the directory for a specific version.
pub fn version_dir(version: String) -> String {
  versions_dir() <> "/" <> version
}

/// Return the path to the caffeine binary for a version.
pub fn caffeine_binary(version: String) -> String {
  version_dir(version) <> "/caffeine"
}

/// Return the path to the current version symlink.
pub fn current_link() -> String {
  cvm_home() <> "/current"
}

/// Strip a leading "v" prefix from a version string.
pub fn strip_v(version: String) -> String {
  case version {
    "v" <> rest -> rest
    _ -> version
  }
}

fn get_env(name: String) -> Result(String, Nil) {
  shellout.command(run: "printenv", with: [name], in: ".", opt: [])
  |> result.map(string.trim)
  |> result.replace_error(Nil)
}

// --- Platform detection ---

/// Detect the current OS and architecture as "os-arch".
pub fn detect_platform() -> Result(String, String) {
  use os <- result.try(detect_os())
  use arch <- result.try(detect_arch())
  Ok(os <> "-" <> arch)
}

fn detect_os() -> Result(String, String) {
  case shell("uname", ["-s"]) {
    Ok("Darwin") -> Ok("macos")
    Ok("Linux") -> Ok("linux")
    Ok(other) -> Error("unsupported OS: " <> other)
    Error(e) -> Error(e)
  }
}

fn detect_arch() -> Result(String, String) {
  case shell("uname", ["-m"]) {
    Ok("x86_64") -> Ok("x64")
    Ok("arm64") | Ok("aarch64") -> Ok("arm64")
    Ok(other) -> Error("unsupported architecture: " <> other)
    Error(e) -> Error(e)
  }
}

fn shell(cmd: String, args: List(String)) -> Result(String, String) {
  shellout.command(run: cmd, with: args, in: ".", opt: [])
  |> result.map(string.trim)
  |> result.map_error(fn(e) { "command failed: " <> cmd <> " " <> e.1 })
}

// --- Version state ---

/// Check whether a version is installed locally.
pub fn is_installed(version: String) -> Bool {
  simplifile.is_file(caffeine_binary(version)) |> result.unwrap(False)
}

/// Read the currently active version from the symlink.
pub fn current_version() -> String {
  shellout.command(run: "readlink", with: [current_link()], in: ".", opt: [])
  |> result.map(fn(target) {
    target
    |> string.trim()
    |> string.split("/")
    |> list.last()
    |> result.unwrap("")
  })
  |> result.unwrap("")
}

/// Read a version string from the .caffeine-version file.
pub fn read_version_file() -> Result(String, Nil) {
  use content <- result.try(
    simplifile.read(".caffeine-version") |> result.replace_error(Nil),
  )
  let v = string.trim(content) |> strip_v()
  use <- bool.guard(v == "", Error(Nil))
  Ok(v)
}
