/// Colored terminal output helpers.

import gleam/io

const red = "\u{001b}[0;31m"

const green = "\u{001b}[0;32m"

const yellow = "\u{001b}[0;33m"

const blue = "\u{001b}[0;34m"

const reset = "\u{001b}[0m"

/// Print an info message in blue.
pub fn info(msg: String) -> Nil {
  io.println(blue <> "::" <> reset <> " " <> msg)
}

/// Print a success message in green.
pub fn ok(msg: String) -> Nil {
  io.println(green <> "ok:" <> reset <> " " <> msg)
}

/// Print a warning message in yellow.
pub fn warn(msg: String) -> Nil {
  io.println(yellow <> "warn:" <> reset <> " " <> msg)
}

/// Print an error message in red to stderr.
pub fn error(msg: String) -> Nil {
  io.println_error(red <> "error:" <> reset <> " " <> msg)
}
