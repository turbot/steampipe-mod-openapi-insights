benchmark "component_parameter" {
  title       = "Component Parameter"
  description = ""

  children = [
    control.component_parameter_definition_unused
  ]
}

control "component_parameter_definition_unused" {
  title       = "Parameter should be used as reference somewhere"
  description = ""
  sql         = query.component_parameter_definition_unused.sql
}
