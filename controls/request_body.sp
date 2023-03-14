benchmark "request_body" {
  title       = "Request Body"
  description = "Request Bodies Best Practices."

  children = [
    control.component_request_body_definition_unused
  ]
}

control "component_request_body_definition_unused" {
  title       = "Component request body definition should be used as reference somewhere"
  description = "Components request bodies definitions should be referenced or removed from Open API definition."
  severity    = "none"
  sql         = query.component_request_body_definition_unused.sql
}
