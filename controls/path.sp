benchmark "path" {
  title       = "Path"
  description = "Paths Best Practices."

  children = [
    control.path_operation_basic_auth_with_no_cleartext_credentials
  ]
}

control "path_operation_basic_auth_with_no_cleartext_credentials" {
  title       = "Cleartext credentials with basic authentication for operation should be allowed"
  description = "Cleartext credentials over unencrypted channel should not be accepted for the operation."
  severity    = "high"
  sql         = query.path_operation_basic_auth_with_no_cleartext_credentials.sql
}
