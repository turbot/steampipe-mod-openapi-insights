benchmark "response" {
  title       = "Response"
  description = "Responses Best Practices."

  children = [
    control.components_response_definition_unused,
    control.success_response_code_undefined_trace_operation
  ]
}

control "components_response_definition_unused" {
  title       = "Component response should be used as reference somewhere"
  description = "Components responses definitions should be referenced or removed from Open API definition."
  severity    = "none"
  sql         = query.components_response_definition_unused.sql
}

control "success_response_code_undefined_trace_operation" {
  title       = "Trace should have the '200' successful code set"
  description = "Trace should define the '200' successful code."
  severity    = "medium"
  sql         = query.success_response_code_undefined_trace_operation.sql
}
