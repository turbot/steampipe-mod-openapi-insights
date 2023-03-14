with component_response_with_unknown_prefix as (
  select
    path,
    concat('paths.', key, '.content.', c ->> 'contentType') as content_type
    --array_agg(concat('components.', key, '.content.', c ->> 'contentType')) as prefix_paths
  from
    openapi_component_response,
    jsonb_array_elements(content) as c
  where
    split_part(c ->> 'contentType', '/', 1) not in ('application', 'audio', 'font', 'example', 'image', 'message', 'model', 'multipart', 'text', 'video')
),
path_response_with_unknown_prefix as (
  select
    path,
    concat('components.', api_path, '.responses.', response_status, '.content.', c ->> 'contentType') as content_type
  from
    openapi_path_response,
    jsonb_array_elements(content) as c
  where
    split_part(c ->> 'contentType', '/', 1) not in ('application', 'audio', 'font', 'example', 'image', 'message', 'model', 'multipart', 'text', 'video')
    and response_ref is null
),
aggregated_result as (
  select * from component_response_with_unknown_prefix
    union
  select * from path_response_with_unknown_prefix
),
group_result_by_path as (
  select
    path,
    array_agg(content_type) as content_types
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
    when g.path is null then i.title || ' has no unknown prefix defined.'
    else i.title || ' has unknown prefixes defined in following path(s): ' || array_to_string(g.content_types, ', ') || '.'
  end as reason,
  i.path
from
  openapi_info as i
  left join group_result_by_path as g on i.path = g.path;
