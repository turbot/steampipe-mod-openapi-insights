-- List all available header definitions
with list_available_headers as (
  select
    path,
    array_agg(key) as header_refs
  from
    openapi_component_header
  group by
    path
),
-- List all headers references used
list_used_headers as (
  select
    path,
    array_agg(distinct split_part(value ->> '$ref', '/', '4')) as headers
  from
    openapi_path_response,
    jsonb_each(headers)
  where
    (value ->> '$ref') is not null
  group by
    path
),
-- List all unused parameter definitons
diff_data as (
  select path, unnest(header_refs) as data from list_available_headers
    except
  select path, unnest(headers) as data from list_used_headers
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
    when a.path is null then i.title || ' has no unused headers defined.'
    else i.title || ' has following unused headers defined: ' || array_to_string(a.diff, ', ') || '.'
  end as reason,
  i.path
from
  openapi_info as i
  left join diff_data_agg as a on i.path = a.path;
