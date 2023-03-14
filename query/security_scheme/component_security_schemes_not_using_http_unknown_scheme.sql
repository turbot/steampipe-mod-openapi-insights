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
