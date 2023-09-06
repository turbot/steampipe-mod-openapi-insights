locals {
  info_best_practices_common_tags = merge(local.openapi_insights_common_tags, {
    service = "OpenAPI/Info"
  })
}

benchmark "info_best_practices" {
  title       = "Info Best Practices"
  description = "Best practices for Info."

  children = [
    control.global_scheme_define_http,
  ]

  tags = merge(local.info_best_practices_common_tags, {
    type = "Benchmark"
  })
}

control "global_scheme_define_http" {
  title       = "Ensure that global schemes use https protocol"
  description = "Ensure that global schemes use 'https' protocol instead of 'http'- version 2.0 files."
  severity    = "high"
  sql         = <<-EOQ
    select
      title as resource,
      case
        when global_schemes @> '["https"]' then 'ok'
        else 'alarm'
      end as status,
      case
        when global_schemes @> '["https"]' then title || ' global schemes use https protocol.'
        else title || ' global schemes does not use https protocol.'
      end as reason,
      path
    from
      openapi_v2_info;
  EOQ
}

