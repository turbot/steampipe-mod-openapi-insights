benchmark "response" {
  title       = "Response"
  description = "Responses Best Practices."

  children = [
    control.components_response_definition_unused,
    control.path_response_success_response_code_undefined_trace_operation,
    control.response_content_with_no_unknown_prefix
  ]
}

control "components_response_definition_unused" {
  title       = "Component response should be used as reference somewhere"
  description = "Components responses definitions should be referenced or removed from Open API definition."
  severity    = "none"
  sql         = query.components_response_definition_unused.sql
}

control "path_response_success_response_code_undefined_trace_operation" {
  title       = "Trace should have the '200' successful code set"
  description = "Trace should define the '200' successful code."
  severity    = "medium"
  sql         = query.path_response_success_response_code_undefined_trace_operation.sql
}

control "response_content_with_no_unknown_prefix" {
  title       = "Trace should have the '200' successful code set"
  description = "The media type prefix should be set as 'application', 'audio', 'font', 'example', 'image', 'message', 'model', 'multipart', 'text' or 'video'."
  severity    = "none"
  sql         = query.response_content_with_no_unknown_prefix.sql
}
