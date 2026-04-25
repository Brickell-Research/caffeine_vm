/// Background-ish check for newer caffeine releases.
/// Caches the latest version on disk for 24h to avoid hitting the network
/// on every invocation. Opt-out via CVM_NO_UPDATE_CHECK=1.

import cvm/env
import cvm/output
import gleam/bool
import gleam/int
import gleam/list
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/result
import gleam/string
import shellout
import simplifile

const cache_ttl_seconds = 86_400

const fetch_timeout_seconds = "3"

const repo = "Brickell-Research/caffeine_lang"

/// Print a notice if a newer caffeine version is available. Silent on
/// any failure — this is a courtesy, not a critical path.
pub fn maybe_notify() -> Nil {
  use <- bool.guard(opted_out(), Nil)
  let current = env.current_version()
  use <- bool.guard(current == "", Nil)

  case latest_version() {
    Ok(latest) ->
      case is_newer(latest, current) {
        True ->
          output.warn(
            "a new version of Caffeine is available: "
            <> latest
            <> " (current: "
            <> current
            <> ")\n      run: cvm install latest && cvm use latest",
          )
        False -> Nil
      }
    Error(_) -> Nil
  }
}

fn opted_out() -> Bool {
  case shellout.command(run: "printenv", with: ["CVM_NO_UPDATE_CHECK"], in: ".", opt: []) {
    Ok(v) -> string.trim(v) != ""
    Error(_) -> False
  }
}

fn cache_path() -> String {
  env.cvm_home() <> "/.update_check"
}

fn latest_version() -> Result(String, String) {
  case read_cache() {
    Ok(#(ts, version)) ->
      case is_fresh(ts) {
        True -> Ok(version)
        False -> refresh()
      }
    Error(_) -> refresh()
  }
}

fn refresh() -> Result(String, String) {
  use latest <- result.try(fetch_latest())
  let _ = write_cache(now(), latest)
  Ok(latest)
}

fn read_cache() -> Result(#(Int, String), Nil) {
  use content <- result.try(
    simplifile.read(cache_path()) |> result.replace_error(Nil),
  )
  case string.split(string.trim(content), "\n") {
    [ts_str, version, ..] -> {
      use ts <- result.try(int.parse(ts_str) |> result.replace_error(Nil))
      use <- bool.guard(version == "", Error(Nil))
      Ok(#(ts, version))
    }
    _ -> Error(Nil)
  }
}

fn write_cache(ts: Int, version: String) -> Result(Nil, Nil) {
  let _ = simplifile.create_directory_all(env.cvm_home())
  simplifile.write(cache_path(), int.to_string(ts) <> "\n" <> version <> "\n")
  |> result.replace_error(Nil)
}

fn is_fresh(ts: Int) -> Bool {
  now() - ts < cache_ttl_seconds
}

fn now() -> Int {
  case shellout.command(run: "date", with: ["+%s"], in: ".", opt: []) {
    Ok(s) -> int.parse(string.trim(s)) |> result.unwrap(0)
    Error(_) -> 0
  }
}

fn fetch_latest() -> Result(String, String) {
  let url = "https://api.github.com/repos/" <> repo <> "/releases/latest"
  case
    shellout.command(
      run: "curl",
      with: ["-sS", "--fail", "--max-time", fetch_timeout_seconds, url],
      in: ".",
      opt: [],
    )
  {
    Ok(body) -> extract_tag(body)
    Error(#(_, msg)) -> Error(msg)
  }
}

@internal
pub fn extract_tag(body: String) -> Result(String, String) {
  case string.split(body, "\"tag_name\"") {
    [_, rest, ..] ->
      case string.split(rest, "\"") {
        [_, tag, ..] -> Ok(strip_v(tag))
        _ -> Error("malformed tag_name")
      }
    _ -> Error("no tag_name in response")
  }
}

fn strip_v(s: String) -> String {
  case s {
    "v" <> rest -> rest
    _ -> s
  }
}

/// True iff `latest` is strictly greater than `current` under semver-ish
/// dotted-int comparison. Non-numeric segments are dropped.
@internal
pub fn is_newer(latest: String, current: String) -> Bool {
  compare_versions(parse_version(latest), parse_version(current)) == Gt
}

fn parse_version(v: String) -> List(Int) {
  v
  |> string.split(".")
  |> list.filter_map(int.parse)
}

fn compare_versions(a: List(Int), b: List(Int)) -> Order {
  case a, b {
    [], [] -> Eq
    [], [y, ..] ->
      case y > 0 {
        True -> Lt
        False -> compare_versions([], list.drop(b, 1))
      }
    [x, ..], [] ->
      case x > 0 {
        True -> Gt
        False -> compare_versions(list.drop(a, 1), [])
      }
    [x, ..xs], [y, ..ys] ->
      case int.compare(x, y) {
        Eq -> compare_versions(xs, ys)
        other -> other
      }
  }
}
