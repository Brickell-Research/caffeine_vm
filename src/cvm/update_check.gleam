/// On startup, check if a newer caffeine release is available and print a
/// notice. Silent on any failure — this is a courtesy, not a critical path.

import cvm/env
import cvm/github
import cvm/output
import gleam/bool
import gleam/int
import gleam/list
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/string

pub fn maybe_notify() -> Nil {
  let current = env.current_version()
  use <- bool.guard(current == "", Nil)

  case github.resolve_latest() {
    Ok(latest) ->
      case is_newer(latest, current) {
        True ->
          output.warn(
            "a new version of Caffeine is available: "
            <> latest
            <> " (current: "
            <> current
            <> ")\n      run: cvm install latest",
          )
        False -> Nil
      }
    Error(_) -> Nil
  }
}

@internal
pub fn is_newer(latest: String, current: String) -> Bool {
  compare_versions(parse(latest), parse(current)) == Gt
}

fn parse(v: String) -> List(Int) {
  v |> string.split(".") |> list.filter_map(int.parse)
}

fn compare_versions(a: List(Int), b: List(Int)) -> Order {
  case a, b {
    [], [] -> Eq
    [], [y, ..ys] ->
      case int.compare(y, 0) {
        Eq -> compare_versions([], ys)
        _ -> Lt
      }
    [x, ..xs], [] ->
      case int.compare(x, 0) {
        Eq -> compare_versions(xs, [])
        _ -> Gt
      }
    [x, ..xs], [y, ..ys] ->
      case int.compare(x, y) {
        Eq -> compare_versions(xs, ys)
        other -> other
      }
  }
}
