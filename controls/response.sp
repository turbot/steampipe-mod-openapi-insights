benchmark "response" {
  title       = "Response Best Practices"
  description = "Best practices for responses."

  children = [
    control.components_response_definition_unused,
    control.path_response_success_response_code_undefined_trace_operation,
    control.response_content_with_no_unknown_prefix,
    control.component_path_response_content_object_with_no_schema
  ]
}

control "components_response_definition_unused" {
  title       = "Component response should be used as reference somewhere"
  description = "Components responses definitions should be referenced or removed from Open API definition."
  severity    = "none"
  sql         = <<-EOQ
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
  EOQ
}

control "path_response_success_response_code_undefined_trace_operation" {
  title       = "Trace should have the '200' successful code set"
  description = "Trace should define the '200' successful code."
  severity    = "medium"
  sql         = <<-EOQ
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
  EOQ
}

control "response_content_with_no_unknown_prefix" {
  title       = "Trace should have the '200' successful code set"
  description = "The media type prefix should be set as 'application', 'audio', 'font', 'example', 'image', 'message', 'model', 'multipart', 'text' or 'video'."
  severity    = "none"
  sql         = <<-EOQ
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
  EOQ
}

control "component_path_response_content_object_with_no_schema" {
  title       = "Response object should have schema defined for content"
  description = "The content object in response should have the attribute 'schema' defined."
  severity    = "medium"
  sql         = <<-EOQ
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
  EOQ
}
