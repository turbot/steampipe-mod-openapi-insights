with component_request_body_with_incorrect_media_type as (
  select
    path,
    concat('components.requestBodies.', key, '.content.', c ->> 'contentType') as paths
  from
    openapi_component_request_body,
    jsonb_array_elements(content) as c
  where
    c ->> 'encoding' is not null
    and c ->> 'contentType' not in ('multipart', 'application/x-www-form-urlencoded')
),
path_request_body_with_incorrect_media_type as (
  select
    path,
    concat(api_path, '.requestBody.content.', c ->> 'contentType') as paths
  from
    openapi_path_request_body,
    jsonb_array_elements(content) as c
  where
    c ->> 'encoding' is not null
    and request_body_ref is null
    and c ->> 'contentType' not in ('multipart', 'application/x-www-form-urlencoded')
),
aggregated_result as (
  select * from component_request_body_with_incorrect_media_type
    union
  select * from path_request_body_with_incorrect_media_type
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
    when g.path is null then i.title || ' request body has correct media type.'
    else i.title || ' has following rquest body with incorrect media type: ' || array_to_string(g.paths, ', ') || '.'
  end as reason,
  i.path
from
  openapi_info as i
  left join group_result_by_path as g on i.path = g.path;
