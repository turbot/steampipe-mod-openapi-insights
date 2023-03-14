benchmark "schema" {
  title       = "Schema"
  description = "Schemas Best Practices."

  children = [
    control.component_schema_not_with_both_read_only_and_write_only
  ]
}

control "component_schema_not_with_both_read_only_and_write_only" {
  title       = "Schema should not have both 'writeOnly' and 'readOnly' set to true"
  description = "Schema should not have both 'writeOnly' and 'readOnly' set to true."
  severity    = "none"
  sql         = query.component_schema_not_with_both_read_only_and_write_only.sql
}
