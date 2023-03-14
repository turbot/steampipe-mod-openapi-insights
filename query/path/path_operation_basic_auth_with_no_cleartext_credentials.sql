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