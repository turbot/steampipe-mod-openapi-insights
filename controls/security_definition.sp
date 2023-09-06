locals {
  security_definition_best_practices_common_tags = merge(local.openapi_insights_common_tags, {
    service = "OpenAPI/SecurityDefinition"
  })
}

benchmark "security_definition_best_practices" {
  title       = "SecurityDefinition Best Practices"
  description = "Best practices for Security Definition."

  children = [
    control.security_definition_defined,
    control.security_not_using_password_flow_in_oauth2,
    control.security_definition_using_implicit_flow,
    control.security_definition_using_basic_auth,
    control.security_definition_global_scope_defined
  ]

  tags = merge(local.security_definition_best_practices_common_tags, {
    type = "Benchmark"
  })
}

control "security_definition_defined" {
  title       = "Ensure that securityDefinitions is defined and not empty"
  description = "Ensure that securityDefinitions is defined and not empty - version 2.0 files."
  severity    = "high"
  sql         = <<-EOQ
    with security_definition_path as (
      select
        distinct path
      from
        openapi_v2_security_definition
    )
    select
      i.title as resource,
      case
        when d.path is null then 'alarm'
        else 'ok'
      end as status,
      case
        when d.path is null then title || ' securityDefinitions is empty.'
        else title || ' securityDefinitions is defined.'
      end as reason,
      i.path
    from
      openapi_v2_info as i
      left join security_definition_path as d on d.path = i.path;
  EOQ
}

control "security_not_using_password_flow_in_oauth2" {
  title       = "Ensure that security is not using password flow in OAuth2 authentication"
  description = "Ensure that security is not using 'password' flow in OAuth2 authentication - version 2.0 files."
  severity    = "high"
  sql         = <<-EOQ
    with security_definition_path as (
      select
        distinct path
      from
        openapi_v2_security_definition
      where
        type = 'oauth2'
        and flow = 'password'
    )
    select
      i.title as resource,
      case
        when d.path is null then 'ok'
        else 'alarm'
      end as status,
      case
        when d.path is null then title || ' security is not using password flow in OAuth2 authentication.'
        else title || ' security is using password flow in OAuth2 authentication.'
      end as reason,
      i.path
    from
      openapi_v2_info as i
      left join security_definition_path as d on d.path = i.path;
  EOQ
}

control "security_definition_using_implicit_flow" {
  title       = "Ensure no security definition is using implicit flow on OAuth2"
  description = "Ensure no security definition is using implicit flow on OAuth2 - version 2.0 files."
  severity    = "high"
  sql         = <<-EOQ
    with security_definition_path as (
      select
        distinct path
      from
        openapi_v2_security_definition
      where
        flow = 'implicit'
    )
    select
      i.title as resource,
      case
        when d.path is null then 'ok'
        else 'alarm'
      end as status,
      case
        when d.path is null then title || ' security definition is not using implicit flow.'
        else title || ' security definition is using implicit flow.'
      end as reason,
      i.path
    from
      openapi_v2_info as i
      left join security_definition_path as d on d.path = i.path;
  EOQ
}

control "security_definition_using_basic_auth" {
  title       = "Ensure security definitions do not use basic auth"
  description = "Ensure security definitions do not use basic auth - version 2.0 files."
  severity    = "high"
  sql         = <<-EOQ
    with security_definition_path as (
      select
        distinct path
      from
        openapi_v2_security_definition
      where
        type = 'basic'
    )
    select
      i.title as resource,
      case
        when d.path is null then 'ok'
        else 'alarm'
      end as status,
      case
        when d.path is null then title || ' security definition is not using basic auth.'
        else title || ' security definition is using basic auth.'
      end as reason,
      i.path
    from
      openapi_v2_info as i
      left join security_definition_path as d on d.path = i.path;
  EOQ
}

control "security_definition_global_scope_defined" {
  title       = "Ensure that global security scope is defined in securityDefinitions"
  description = "Ensure that global security scope is defined in securityDefinitions - version 2.0 files."
  severity    = "high"
  sql         = <<-EOQ
    with security_definition_path as (
      select
        distinct path
      from
        openapi_v2_security_definition
      where
        scopes is not null
    )
    select
      i.title as resource,
      case
        when d.path is null then 'alarm'
        else 'ok'
      end as status,
      case
        when d.path is null then title || ' global security scope is not defined in securityDefinition.'
        else title || ' global security scope is defined in securityDefinition.'
      end as reason,
      i.path
    from
      openapi_v2_info as i
      left join security_definition_path as d on d.path = i.path;
  EOQ
}
