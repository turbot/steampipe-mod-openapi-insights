-- Get the list of response code set defined for every TRACE API methods
with list_trace_methods as (
  select
    path,
    api_path,
    array_agg(response_status) as status_codes
  from
    openapi_path_response
  where
    api_method = 'TRACE'
  group by
    path,
    api_path
),
-- Search for the API paths that has TRACE method defines without 200 successful code set
trace_method_with_no_200_response_code as (
  select
    path,
    array_agg(api_path) as api_paths
  from
    list_trace_methods
  where
    not status_codes @> '{"200"}'
  group by
    path
)
select
  i.title as resource,
  case
    when a.path is null then 'ok'
    else 'alarm'
  end as status,
  case
    when a.path is null then i.title || ' has no trace method defined without ''200'' successful code set.'
    else i.title || ' has following trace methods defined without ''200'' successful code set: ' || array_to_string(a.api_paths, ', ') || '.'
  end as reason,
  i.path
from
  openapi_info as i
  left join trace_method_with_no_200_response_code as a on i.path = a.path;
