-- List all parameter references used by the API path
with list_used_response_defs as (
  select
    path,
    array_agg(distinct split_part(response_ref, '/', '4')) as resp
  from
    openapi_path_response
  where
    response_ref is not null
  group by
    path
),
-- List all available parameter definitions
all_responses_definition as (
  select
    path,
    array_agg(key) as resp_defs
  from
    openapi_component_response
  group by
    path
),
-- List all unused parameter definitons
diff_data as (
  select path, unnest(resp_defs) as data from all_responses_definition
    except
  select path, unnest(resp) as data from list_used_response_defs
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
    when a.path is null then i.title || ' has no unused response definition defined.'
    else i.title || ' has following unused response definition defined: ' || array_to_string(diff, ', ') || '.'
  end as reason,
  i.path
from
  openapi_info as i
  left join diff_data_agg as a on i.path = a.path;
