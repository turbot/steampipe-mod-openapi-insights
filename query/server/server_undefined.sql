with server_count as (
  select
    path,
    count(*)
  from
    openapi_server
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
    when s.path is null or s.count < 1 then i.title || ' server array is empty.'
    else i.title || ' has ' || s.count || ' server(s) defined.'
  end as reason,
  i.path
from
  openapi_info as i
  left join server_count as s on i.path = s.path;
