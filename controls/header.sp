benchmark "header" {
  title       = "Header"
  description = "Headers Best Practices."

  children = [
    control.component_header_definition_unused
  ]
}

control "component_header_definition_unused" {
  title       = "Component header definition should be used as reference somewhere"
  description = "Components headers definitions should be referenced or removed from Open API definition."
  severity    = "none"
  sql         = query.component_header_definition_unused.sql
}
