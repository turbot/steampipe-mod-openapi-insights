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
