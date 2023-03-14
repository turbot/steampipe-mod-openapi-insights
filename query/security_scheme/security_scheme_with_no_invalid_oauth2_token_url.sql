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
