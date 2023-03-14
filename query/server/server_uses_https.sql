with server_not_using_https_protocol as (
  select
    path,
    array_agg(url) as urls
  from
    openapi_server
  where
    url not like 'https:%'
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
    when s.path is null then i.title || ' server urls uses ''HTTPS'' protocol.'
    else i.title || ' has following servers doesn''t use ''HTTPS'' protocol: ' || array_to_string(s.urls, ', ') || '.'
  end as reason,
  i.path
from
  openapi_info as i
  left join server_not_using_https_protocol as s on i.path = s.path;
