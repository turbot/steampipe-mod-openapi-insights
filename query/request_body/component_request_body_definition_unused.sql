-- List all request body references used by the API path
with list_used_request_bodies as (
  select
    path,
    array_agg(distinct split_part(request_body_ref, '/', 4)) as req_bodies
  from
    openapi_path_request_body
  where
    request_body_ref is not null
  group by
    path
),
-- List all available request body definitions
all_request_body_definition as (
  select
    path,
    array_agg(key) as req_body_defs
  from
    openapi_component_request_body
  group by
    path
),
-- List all unused request body definitons
diff_data as (
  select path, unnest(req_body_defs) as data from all_request_body_definition
    except
  select path, unnest(req_bodies) as data from list_used_request_bodies
),
-- Aggregate the list to easily access the list
diff_data_agg as (
  select
    path,
    array_agg(data order by data) as diff
  from
    diff_data
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
    when a.path is null then i.title || ' has no unused request body definition defined.'
    else i.title || ' has following unused request body definition defined: ' || array_to_string(a.diff, ', ') || '.'
  end as reason,
  i.path
from
  openapi_info as i
  left join diff_data_agg as a on i.path = a.path;
