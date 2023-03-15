locals {
  schema_best_practices_common_tags = merge(local.openapi_insights_common_tags, {
    service = "OpenAPI/Schema"
  })
}

benchmark "schema_best_practices" {
  title       = "Schema Best Practices"
  description = "Best practices for schema."

  children = [
    control.component_schema_not_with_both_read_only_and_write_only
  ]

  tags = merge(local.schema_best_practices_common_tags, {
    type = "Benchmark"
  })
}

control "component_schema_not_with_both_read_only_and_write_only" {
  title       = "Schema should not have both 'writeOnly' and 'readOnly' set to true"
  description = "Schema should not have both 'writeOnly' and 'readOnly' set to true."
  severity    = "none"
  sql         = <<-EOQ
    with schema_with_both_read_only_and_write_only as (
      select
        path,
        array_agg(name) as schema_names
      from
        openapi_component_schema
      where
        read_only
        and write_only
      group by
        path
    )
    select
      i.title as resource,
      case
        when s.path is null then 'ok'
        else 'alarm'
      end as status,
      case
        when s.path is null then i.title || ' has no schema defined with both read-only and write-only configured.'
        else i.title || ' has following schema with both read-only and write-only configured: ' || array_to_string(s.schema_names, ', ') || '.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join schema_with_both_read_only_and_write_only as s on i.path = s.path;
  EOQ
}
