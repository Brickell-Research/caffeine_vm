import cvm/env
import gleeunit/should

// ==== strip_v ====
// * removes leading "v" prefix
// * leaves bare versions unchanged
// * handles "v" alone
// * handles empty string
pub fn strip_v_with_prefix_test() {
  env.strip_v("v4.6.0")
  |> should.equal("4.6.0")
}

pub fn strip_v_without_prefix_test() {
  env.strip_v("4.6.0")
  |> should.equal("4.6.0")
}

pub fn strip_v_just_v_test() {
  env.strip_v("v")
  |> should.equal("")
}

pub fn strip_v_empty_test() {
  env.strip_v("")
  |> should.equal("")
}
