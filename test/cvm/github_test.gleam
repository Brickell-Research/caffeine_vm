import cvm/github
import gleam/string
import gleeunit/should

// ==== download_url ====
// * builds correct URL for linux
// * builds correct URL for macos
// * uses .zip extension for windows
pub fn download_url_linux_test() {
  github.download_url("4.6.0", "linux-x64")
  |> should.equal(
    "https://github.com/Brickell-Research/caffeine_lang/releases/download/v4.6.0/caffeine-4.6.0-linux-x64.tar.gz",
  )
}

pub fn download_url_macos_test() {
  github.download_url("4.5.1", "macos-arm64")
  |> should.equal(
    "https://github.com/Brickell-Research/caffeine_lang/releases/download/v4.5.1/caffeine-4.5.1-macos-arm64.tar.gz",
  )
}

pub fn download_url_windows_test() {
  let url = github.download_url("4.6.0", "windows-x64")
  should.be_true(string.ends_with(url, ".zip"))
}

// ==== find_tag_names ====
// * extracts tags from JSON array
// * returns empty list for no matches
// * handles single release JSON
pub fn find_tag_names_multiple_test() {
  let body =
    "[{\"tag_name\": \"v4.6.0\"}, {\"tag_name\": \"v4.5.1\"}, {\"tag_name\": \"v4.5.0\"}]"
  github.find_tag_names(body)
  |> should.equal(["v4.6.0", "v4.5.1", "v4.5.0"])
}

pub fn find_tag_names_empty_test() {
  github.find_tag_names("{}")
  |> should.equal([])
}

pub fn find_tag_names_single_test() {
  let body = "{\"tag_name\": \"v4.6.0\", \"name\": \"Release 4.6.0\"}"
  github.find_tag_names(body)
  |> should.equal(["v4.6.0"])
}

// ==== extract_tag ====
// * extracts and strips v prefix from single release
// * returns error for missing tag
pub fn extract_tag_ok_test() {
  let body = "{\"tag_name\": \"v4.6.0\", \"name\": \"Release 4.6.0\"}"
  github.extract_tag(body)
  |> should.equal(Ok("4.6.0"))
}

pub fn extract_tag_missing_test() {
  github.extract_tag("{\"name\": \"no tag here\"}")
  |> should.be_error()
}

// ==== extract_tags ====
// * extracts and strips v prefix from multiple releases
// * returns empty list for no releases
pub fn extract_tags_multiple_test() {
  let body = "[{\"tag_name\": \"v4.6.0\"}, {\"tag_name\": \"v4.5.1\"}]"
  github.extract_tags(body)
  |> should.equal(["4.6.0", "4.5.1"])
}

pub fn extract_tags_empty_test() {
  github.extract_tags("[]")
  |> should.equal([])
}
