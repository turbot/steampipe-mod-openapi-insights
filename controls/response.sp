benchmark "response" {
  title       = "Response"
  description = ""

  children = [
    control.components_response_definition_unused,
    control.success_response_code_undefined_trace_operation
  ]
}

control "components_response_definition_unused" {
  title       = "Response should be used as reference somewhere"
  description = ""
  sql         = query.components_response_definition_unused.sql
}

control "success_response_code_undefined_trace_operation" {
  title       = "Trace should have the '200' successful code set"
  description = ""
  sql         = query.success_response_code_undefined_trace_operation.sql
}
