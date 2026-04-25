import cvm/update_check
import gleeunit/should

// ==== is_newer ====
// * detects patch bumps
// * detects minor bumps
// * detects major bumps
// * handles two-digit segments correctly (5.10.0 > 5.9.0)
// * returns false when equal
// * returns false when latest < current
// * tolerates a leading "v" being absent (caller already strips)
pub fn is_newer_patch_test() {
  update_check.is_newer("4.6.1", "4.6.0")
  |> should.be_true()
}

pub fn is_newer_minor_test() {
  update_check.is_newer("4.7.0", "4.6.9")
  |> should.be_true()
}

pub fn is_newer_major_test() {
  update_check.is_newer("5.0.0", "4.99.99")
  |> should.be_true()
}

pub fn is_newer_two_digit_segment_test() {
  update_check.is_newer("5.10.0", "5.9.0")
  |> should.be_true()
}

pub fn is_newer_equal_test() {
  update_check.is_newer("5.0.11", "5.0.11")
  |> should.be_false()
}

pub fn is_newer_older_test() {
  update_check.is_newer("4.5.0", "4.6.0")
  |> should.be_false()
}

pub fn is_newer_trailing_zero_test() {
  update_check.is_newer("5.0", "5.0.0")
  |> should.be_false()
}

// ==== extract_tag ====
// * pulls tag_name out of a release JSON body
// * strips a leading v
// * errors when tag_name is absent
pub fn extract_tag_ok_test() {
  update_check.extract_tag("{\"tag_name\": \"v5.1.0\"}")
  |> should.equal(Ok("5.1.0"))
}

pub fn extract_tag_no_v_test() {
  update_check.extract_tag("{\"tag_name\": \"5.1.0\"}")
  |> should.equal(Ok("5.1.0"))
}

pub fn extract_tag_missing_test() {
  update_check.extract_tag("{}")
  |> should.be_error()
}
