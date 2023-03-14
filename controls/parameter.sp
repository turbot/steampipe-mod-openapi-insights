benchmark "parameter" {
  title       = "Parameter"
  description = "Parameters Best Practices."

  children = [
    control.component_parameter_definition_unused
  ]
}

control "component_parameter_definition_unused" {
  title       = "Component parameter definition should be used as reference somewhere"
  description = "Components parameters definitions should be referenced or removed from Open API definition."
  severity    = "none"
  sql         = query.component_parameter_definition_unused.sql
}
