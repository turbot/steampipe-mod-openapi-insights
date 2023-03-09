benchmark "component_header" {
  title       = "Component Header"
  description = ""

  children = [
    control.components_header_definition_unused
  ]
}

control "components_header_definition_unused" {
  title       = "Header should be used as reference somewhere"
  description = ""
  sql         = query.components_header_definition_unused.sql
}
