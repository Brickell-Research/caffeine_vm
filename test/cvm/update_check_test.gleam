import cvm/update_check
import gleeunit/should

// ==== is_newer ====
// * detects patch / minor / major bumps
// * handles two-digit segments correctly (5.10.0 > 5.9.0)
// * returns false on equal or older
pub fn is_newer_patch_test() {
  update_check.is_newer("4.6.1", "4.6.0") |> should.be_true()
}

pub fn is_newer_minor_test() {
  update_check.is_newer("4.7.0", "4.6.9") |> should.be_true()
}

pub fn is_newer_major_test() {
  update_check.is_newer("5.0.0", "4.99.99") |> should.be_true()
}

pub fn is_newer_two_digit_segment_test() {
  update_check.is_newer("5.10.0", "5.9.0") |> should.be_true()
}

pub fn is_newer_equal_test() {
  update_check.is_newer("5.0.11", "5.0.11") |> should.be_false()
}

pub fn is_newer_older_test() {
  update_check.is_newer("5.0.5", "5.0.11") |> should.be_false()
}

pub fn is_newer_trailing_zero_test() {
  update_check.is_newer("5.0", "5.0.0") |> should.be_false()
}
