benchmark "component_response" {
  title       = "Component Response"
  description = ""

  children = [
    control.components_response_definition_unused
  ]
}

control "components_response_definition_unused" {
  title       = "Response should be used as reference somewhere"
  description = ""
  sql         = query.components_response_definition_unused.sql
}
