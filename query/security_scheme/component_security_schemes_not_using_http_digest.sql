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
