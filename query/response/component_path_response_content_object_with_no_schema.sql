with component_response_with_no_schema as (
  select
    path,
    concat('components.responses.', key, '.content.', c ->> 'contentType') as paths
  from
    openapi_component_response,
    jsonb_array_elements(content) as c
  where
    c ->> 'schema' is null
),
path_response_with_no_schema as (
  select
    path,
    concat(api_path, '.responses.', response_status, '.content.', c ->> 'contentType') as paths
  from
    openapi_path_response,
    jsonb_array_elements(content) as c
  where
    c ->> 'schema' is null
    and response_ref is null
),
aggregated_result as (
  select * from component_response_with_no_schema
    union
  select * from path_response_with_no_schema
),
group_result_by_path as (
  select
    path,
    array_agg(paths) as paths
  from
    aggregated_result
  group by
    path
)
select
  i.title as resource,
  case
    when g.path is null then 'ok'
    else 'alarm'
  end as status,
  case
    when g.path is null then i.title || ' response object has proper schema defined.'
    else i.title || ' has following response object with no schema defined: ' || array_to_string(g.paths, ', ') || '.'
  end as reason,
  i.path
from
  openapi_info as i
  left join group_result_by_path as g on i.path = g.path;
