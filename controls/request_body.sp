benchmark "request_body" {
  title       = "Request Body"
  description = ""

  children = [
    control.component_request_body_definition_unused
  ]
}

control "component_request_body_definition_unused" {
  title       = "Request body should be used as reference somewhere"
  description = ""
  sql         = query.component_request_body_definition_unused.sql
}
