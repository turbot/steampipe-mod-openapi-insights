select
  api_path || ' : ' || (path_server ->> 'url') as resource,
  case
    when path_server ->> 'url' like 'https:%' then 'ok'
    else 'alarm'
  end as status,
  case
    when path_server ->> 'url' like 'https:%' then 'Path server url uses ''HTTPS'' protocol.'
    else 'Path server url not uses ''HTTPS'' protocol.'
  end as reason,
  path
from
  openapi_path,
  jsonb_array_elements(servers) as path_server;
