benchmark "header" {
  title       = "Header"
  description = ""

  children = [
    control.component_header_definition_unused
  ]
}

control "component_header_definition_unused" {
  title       = "Header should be used as reference somewhere"
  description = ""
  sql         = query.component_header_definition_unused.sql
}
