-- List all parameter references used by the API path
with list_used_parameters as (
  select
    path,
    array_agg(distinct split_part(param ->> '$ref', '/', '4')) as params
  from
    openapi_path,
    jsonb_array_elements(parameters) as param
  where
    (param ->> '$ref') is not null
  group by
    path
),
-- List all available parameter definitions
all_parameters_definition as (
  select
    path,
    array_agg(key) as param_defs
  from
    openapi_component_parameter
  group by
    path
),
-- List all unused parameter definitons
diff_data as (
  select path, unnest(param_defs) as data from all_parameters_definition
    except
  select path, unnest(params) as data from list_used_parameters
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
    when a.path is null then i.title || ' has no unused parameter defined.'
    else i.title || ' has following unused parameters defined: ' || array_to_string(a.diff, ', ') || '.'
  end as reason,
  i.path
from
  openapi_info as i
  left join diff_data_agg as a on i.path = a.path;
