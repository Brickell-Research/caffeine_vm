/// cvm — Caffeine Version Manager.

import argv
import cvm/commands/current
import cvm/commands/install
import cvm/commands/list
import cvm/commands/uninstall
import cvm/commands/switch
import cvm/commands/which
import cvm/output
import shellout

pub fn main() {
  case argv.load().arguments {
    ["install"] -> run(install.run(""))
    ["install", version] -> run(install.run(version))
    ["use", version] -> run(switch.run(version))
    ["list"] -> print(list.run())
    ["list-remote"] -> print(list.remote())
    ["uninstall", version] -> run(uninstall.run(version))
    ["current"] -> print(current.run())
    ["which"] -> print(which.run())
    ["help"] | ["--help"] | ["-h"] | [] -> help()
    [cmd, ..] -> {
      output.error("unknown command: " <> cmd)
      help()
      shellout.exit(1)
    }
  }
}

fn run(result: Result(String, String)) -> Nil {
  case result {
    Ok(msg) -> output.ok(msg)
    Error(msg) -> {
      output.error(msg)
      shellout.exit(1)
    }
  }
}

fn print(result: Result(String, String)) -> Nil {
  case result {
    Ok(msg) -> output.info(msg)
    Error(msg) -> {
      output.error(msg)
      shellout.exit(1)
    }
  }
}

fn help() -> Nil {
  output.info(
    "cvm — Caffeine Version Manager

USAGE
    cvm <command> [args]

COMMANDS
    install [version]    Download and install a version (default: from .caffeine-version)
    use <version>        Switch active version
    list                 List installed versions
    list-remote          List available versions from GitHub
    uninstall <version>  Remove an installed version
    current              Print current active version
    which                Print path to active caffeine binary
    help                 Show this help

EXAMPLES
    cvm install latest
    cvm install 4.6.0
    cvm use 4.5.1
    cvm list",
  )
}
