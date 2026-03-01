/// GitHub Releases API — resolve versions and download binaries.

import gleam/list
import gleam/string
import shellout

const repo = "Brickell-Research/caffeine_lang"

/// Resolve the latest release version (e.g., "4.6.0").
pub fn resolve_latest() -> Result(String, String) {
  let url = "https://api.github.com/repos/" <> repo <> "/releases/latest"
  case curl_get(url) {
    Ok(body) -> extract_tag(body)
    Error(e) -> Error("failed to resolve latest: " <> e)
  }
}

/// List the 20 most recent release versions.
pub fn list_releases() -> Result(List(String), String) {
  let url =
    "https://api.github.com/repos/" <> repo <> "/releases?per_page=20"
  case curl_get(url) {
    Ok(body) -> Ok(extract_tags(body))
    Error(e) -> Error("failed to list releases: " <> e)
  }
}

/// Build the download URL for a specific version and platform.
pub fn download_url(version: String, platform: String) -> String {
  let ext = case string.starts_with(platform, "windows") {
    True -> ".zip"
    False -> ".tar.gz"
  }
  "https://github.com/"
  <> repo
  <> "/releases/download/v"
  <> version
  <> "/caffeine-"
  <> version
  <> "-"
  <> platform
  <> ext
}

/// Download a file from a URL to a local path.
pub fn download(url: String, to dest: String) -> Result(Nil, String) {
  case
    shellout.command(
      run: "curl",
      with: ["-fSL", "-o", dest, url],
      in: ".",
      opt: [],
    )
  {
    Ok(_) -> Ok(Nil)
    Error(#(_, msg)) -> Error("download failed: " <> msg)
  }
}

// --- Internal helpers ---

fn curl_get(url: String) -> Result(String, String) {
  case
    shellout.command(
      run: "curl",
      with: ["-sS", "--fail", url],
      in: ".",
      opt: [],
    )
  {
    Ok(body) -> Ok(body)
    Error(#(_, msg)) -> Error(msg)
  }
}

/// Extract the first tag_name from a JSON response.
@internal
pub fn extract_tag(body: String) -> Result(String, String) {
  case find_tag_names(body) {
    [tag, ..] -> Ok(strip_v(tag))
    [] -> Error("no tag_name found in response")
  }
}

/// Extract all tag_names from a releases list JSON response.
@internal
pub fn extract_tags(body: String) -> List(String) {
  find_tag_names(body)
  |> list.map(strip_v)
}

/// Find all "tag_name": "..." values via string splitting.
/// No JSON library needed, keeps dependencies minimal.
@internal
pub fn find_tag_names(body: String) -> List(String) {
  body
  |> string.split("\"tag_name\"")
  |> list.drop(1)
  |> list.filter_map(fn(chunk) {
    case string.split(chunk, "\"") {
      [_, tag, ..] -> Ok(tag)
      _ -> Error(Nil)
    }
  })
}

fn strip_v(s: String) -> String {
  case s {
    "v" <> rest -> rest
    _ -> s
  }
}
