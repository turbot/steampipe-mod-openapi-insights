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
