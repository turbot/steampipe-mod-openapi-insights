locals {
  security_scheme_best_practices_common_tags = merge(local.openapi_insights_common_tags, {
    service = "OpenAPI/SecurityScheme"
  })
}

benchmark "security_scheme_best_practices" {
  title       = "Security Scheme Best Practices"
  description = "Best practices for security schemes."

  children = [
    control.component_security_scheme_undefined,
    control.component_security_schemes_not_using_http_basic,
    control.component_security_schemes_not_using_http_digest,
    control.component_security_schemes_not_using_http_negotiate,
    control.component_security_schemes_not_using_http_unknown_scheme,
    control.component_security_scheme_not_using_oauth,
    control.component_security_scheme_api_key_not_exposed,
    control.security_scheme_with_no_invalid_oauth2_token_url
  ]

  tags = merge(local.security_scheme_best_practices_common_tags, {
    type = "Benchmark"
  })
}

control "component_security_scheme_api_key_not_exposed" {
  title       = "API Keys should not be transported over network"
  description = "API Keys should not be transported over network."
  severity    = "low"
  sql         = <<-EOQ
    with security_schemes_with_api_key_exposed as (
      select
        path,
        array_agg(key) as security_schemes
      from
        openapi_component_security_scheme
      where
        type = 'apiKey'
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
        when s.path is null then 'The API Key is not transported over network in ' || i.title || '.'
        else 'The API Key is transported over network in ' || i.title || '.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join security_schemes_with_api_key_exposed as s on i.path = s.path;
  EOQ
}

control "component_security_scheme_undefined" {
  title       = "A security scheme on components should be defined"
  description = "Components' securityScheme field must have a valid scheme."
  severity    = "high"
  sql         = <<-EOQ
    with security_scheme_count as (
      select
        path,
        count(*)
      from
        openapi_component_security_scheme
      group by
        path
    )
    select
      i.title as resource,
      case
        when s.path is null or s.count < 1 then 'alarm'
        else 'ok'
      end as status,
      case
        when s.path is null or s.count < 1 then i.title || ' security scheme array is empty.'
        else i.title || ' has ' || s.count || ' security scheme(s) defined.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join security_scheme_count as s on i.path = s.path;
  EOQ
}

control "component_security_schemes_not_using_http_basic" {
  title       = "A Security scheme should not use 'basic' authentication"
  description = "Security Scheme HTTP should not be using basic authentication."
  severity    = "medium"
  sql         = <<-EOQ
    with security_scheme_uses_http_basic as (
      select
        path,
        array_agg(key) as security_schemes
      from
        openapi_component_security_scheme
      where
        type = 'http'
        and scheme = 'basic'
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
        when s.path is null then i.title || ' security scheme(s) not using ''basic'' authentication.'
        else i.title || ' has following security scheme(s) that uses ''basic'' authentication: ' || array_to_string(s.security_schemes, ', ') || '.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join security_scheme_uses_http_basic as s on i.path = s.path;
  EOQ
}

control "component_security_schemes_not_using_http_digest" {
  title       = "A Security scheme should not use 'digest' authentication"
  description = "Security Scheme HTTP should not be using digest authentication."
  severity    = "medium"
  sql         = <<-EOQ
    with security_scheme_uses_http_digest as (
      select
        path,
        array_agg(key) as security_schemes
      from
        openapi_component_security_scheme
      where
        type = 'http'
        and scheme = 'digest'
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
        when s.path is null then i.title || ' security scheme(s) not using ''digest'' authentication.'
        else i.title || ' has following security scheme(s) that uses ''digest'' authentication: ' || array_to_string(s.security_schemes, ', ') || '.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join security_scheme_uses_http_digest as s on i.path = s.path;
  EOQ
}

control "component_security_schemes_not_using_http_negotiate" {
  title       = "A Security scheme should not use 'negotiate' authentication"
  description = "Security Scheme HTTP should not be using negotiate authentication."
  severity    = "medium"
  sql         = <<-EOQ
    with security_scheme_uses_http_negotiate as (
      select
        path,
        array_agg(key) as security_schemes
      from
        openapi_component_security_scheme
      where
        type = 'http'
        and scheme = 'negotiate'
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
        when s.path is null then i.title || ' security scheme(s) not using ''negotiate'' authentication.'
        else i.title || ' has following security scheme(s) that uses ''negotiate'' authentication: ' || array_to_string(s.security_schemes, ', ') || '.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join security_scheme_uses_http_negotiate as s on i.path = s.path;
  EOQ
}

control "component_security_scheme_not_using_oauth" {
  title       = "A security scheme should not use oauth 1.0 security scheme"
  description = "Oauth 1.0 is deprecated, OAuth2 should be used instead."
  severity    = "low"
  sql         = <<-EOQ
    with security_scheme_uses_oauth as (
      select
        path,
        array_agg(key) as security_schemes
      from
        openapi_component_security_scheme
      where
        type = 'http'
        and scheme = 'oauth'
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
        when s.path is null then i.title || ' security scheme(s) not using oauth.'
        else i.title || ' has following security scheme(s) that uses oauth: ' || array_to_string(s.security_schemes, ', ') || '.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join security_scheme_uses_oauth as s on i.path = s.path;
  EOQ
}

control "component_security_schemes_not_using_http_unknown_scheme" {
  title       = "Security scheme should be registered in the IANA Authentication Scheme registry"
  description = "Security Scheme HTTP scheme should be registered in the IANA Authentication Scheme registry."
  severity    = "medium"
  sql         = <<-EOQ
    with security_scheme_with_http_unknown_scheme as (
      select
        path,
        array_agg(key) as security_schemes
      from
        openapi_component_security_scheme
      where
        scheme not in ('basic', 'bearer', 'digest', 'hoba', 'mutual', 'negotiate', 'oauth', 'scram-sha-1', 'scram-sha-256', 'vapid')
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
        when s.path is null then i.title || ' security schemes are registered in the IANA Authentication Scheme registry.'
        else i.title || ' has following security scheme(s) not registered in the IANA Authentication Scheme registry: ' || array_to_string(s.security_schemes, ', ') || '.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join security_scheme_with_http_unknown_scheme as s on i.path = s.path;
  EOQ
}

control "security_scheme_with_no_invalid_oauth2_token_url" {
  title       = "OAuth2 security schema flow tokenUrl must be set with a valid URL"
  description = "OAuth2 security scheme flow requires a valid URL in the tokenUrl field."
  severity    = "medium"
  sql         = <<-EOQ
    with security_schemes_with_invalid_oauth2_token_url as (
      select
        s.path,
        array_agg(concat('components.securitySchemes.', s.key, '.flows.', f.key, '.tokenUrl')) as paths
      from
        openapi_component_security_scheme as s,
        jsonb_each(s.flows) as f
      where
        s.type = 'oauth2'
        and f.key in ('authorizationCode', 'password', 'clientCredentials')
        and not ((f.value ->> 'tokenUrl') ~ '^https?://([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$')
      group by
        s.path
    )
    select
      i.title as resource,
      case
        when s.path is null then 'ok'
        else 'alarm'
      end as status,
      case
        when s.path is null then i.title || ' has no OAuth2 security schema flow with invalid tokenUrl.'
        else i.title || ' has following security schema with invalid tokenUrl: ' || array_to_string(paths, ', ') || '.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join security_schemes_with_invalid_oauth2_token_url as s on i.path = s.path;
  EOQ
}
