locals {
  path_best_practices_common_tags = merge(local.openapi_insights_common_tags, {
    service = "OpenAPI/Path"
  })
}

benchmark "path_best_practices" {
  title       = "Path Best Practices"
  description = "Best practices for paths."

  children = [
    control.path_operation_basic_auth_with_no_cleartext_credentials,
    control.path_operation_objects_produces_undefined,
    control.path_operation_objects_consumes_undefined
  ]

  tags = merge(local.path_best_practices_common_tags, {
    type = "Benchmark"
  })
}

control "path_operation_basic_auth_with_no_cleartext_credentials" {
  title       = "Cleartext credentials with basic authentication for operation should be allowed"
  description = "Cleartext credentials over unencrypted channel should not be accepted for the operation."
  severity    = "high"
  sql         = <<-EOQ
    with cleartext_credentials_with_basic_auth_for_operation as (
      select
        path,
        api_path,
        obj.key as security_key
      from
        openapi_path,
        jsonb_array_elements(security) as s,
        jsonb_each(s) as obj
      where
        obj.value = '[]'
    ),
    security_scheme_with_http_basic_authentication as (
      select
        path,
        key as security_scheme
      from
        openapi_component_security_scheme
      where
        type = 'http'
        and scheme = 'basic'
    ),
    aggregated_result as (
      select
        c.path,
        array_agg(concat('paths.', c.api_path, '.security.', c.security_key)) as paths
      from
        cleartext_credentials_with_basic_auth_for_operation as c
        join security_scheme_with_http_basic_authentication as s on (c.path = s.path and c.security_key = s.security_scheme)
      group by
        c.path
    )
    select
      i.title as resource,
      case
        when s.path is null then 'ok'
        else 'alarm'
      end as status,
      case
        when s.path is null then i.title || ' operations does not allow cleartext credentials over unencrypted channel.'
        else i.title || ' - ' || array_to_string(s.paths, ', ') || ' operation allows cleartext credentials over unencrypted channel.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join aggregated_result as s on i.path = s.path;
  EOQ
}

control "path_operation_objects_produces_undefined" {
  title       = "Path operation objects should have produces field defined for get operations"
  description = "Ensure that operation objects have 'produces' field defined for GET operations - version 2.0 files."
  severity    = "high"
  sql         = <<-EOQ
    with path_operation_objects_produces_undefined as (
      select
        path,
        api_path
      from
        openapi_v2_path
      where
        produces is not null
        and method = 'GET'
    )
    select
      i.title as resource,
      case
        when s.path is null then 'ok'
        else 'alarm'
      end as status,
      case
        when s.path is null then i.title || ' Path operation objects does have produces field defined for get operations.'
        else i.title || ' - ' || s.api_path || ' Path operation objects does not have produces field defined for get operations.'
      end as reason,
      i.path
    from
      openapi_v2_info as i
      left join path_operation_objects_produces_undefined as s on i.path = s.path;
  EOQ
}

control "path_operation_objects_consumes_undefined" {
  title       = "Path operation objects should have consumes field defined for put operations"
  description = "Ensure that operation objects have 'consumes' field defined for PUT operations - version 2.0 files."
  severity    = "high"
  sql         = <<-EOQ
    with path_operation_objects_consumes_undefined as (
      select
        path,
        api_path
      from
        openapi_v2_path
      where
        consumes is not null
        and method = 'PUT'
    )
    select
      i.title as resource,
      case
        when s.path is null then 'ok'
        else 'alarm'
      end as status,
      case
        when s.path is null then i.title || ' Path operation objects does have consumes field defined for put operations.'
        else i.title || ' - ' || s.api_path || ' Path operation objects does not have consumes field defined for put operations.'
      end as reason,
      i.path
    from
      openapi_v2_info as i
      left join path_operation_objects_consumes_undefined as s on i.path = s.path;
  EOQ
}
