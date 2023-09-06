locals {
  request_body_best_practices_common_tags = merge(local.openapi_insights_common_tags, {
    service = "OpenAPI/RequestBody"
  })
}

benchmark "request_body_best_practices" {
  title       = "Request Body Best Practices"
  description = "Best practices for request bodies."

  children = [
    control.component_request_body_definition_unused,
    control.component_path_request_body_object_with_no_incorrect_media_type,
    control.component_path_request_body_content_object_with_no_schema
  ]

  tags = merge(local.request_body_best_practices_common_tags, {
    type = "Benchmark"
  })
}

control "component_request_body_definition_unused" {
  title       = "Component request body definition should be used as reference somewhere"
  description = "Components request bodies definitions should be referenced or removed from Open API definition."
  severity    = "none"
  sql         = <<-EOQ
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
  EOQ
}

control "component_path_request_body_object_with_no_incorrect_media_type" {
  title       = "Request body content type should be 'multipart' or 'application/x-www-form-urlencoded' when 'encoding' is set"
  description = "The field 'content' of the request body object should be set to 'multipart' or 'application/x-www-form-urlencoded' when field 'encoding' is set."
  severity    = "none"
  sql         = <<-EOQ
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
  EOQ
}

control "component_path_request_body_content_object_with_no_schema" {
  title       = "Request body object should have schema defined for content"
  description = "The content object in request body should have the attribute 'schema' defined."
  severity    = "medium"
  sql         = <<-EOQ
    with component_request_body_with_no_schema as (
      select
        path,
        concat('components.requestBodies.', key, '.content.', c ->> 'contentType') as paths
      from
        openapi_component_request_body,
        jsonb_array_elements(content) as c
      where
        c ->> 'schema' is null
    ),
    path_request_body_with_no_schema as (
      select
        path,
        concat(api_path, '.requestBody.content.', c ->> 'contentType') as paths
      from
        openapi_path_request_body,
        jsonb_array_elements(content) as c
      where
        c ->> 'schema' is null
        and request_body_ref is null
    ),
    aggregated_result as (
      select * from component_request_body_with_no_schema
        union
      select * from path_request_body_with_no_schema
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
        when g.path is null then i.title || ' request body object has proper schema defined.'
        else i.title || ' has following rquest body object with no schema defined: ' || array_to_string(g.paths, ', ') || '.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join group_result_by_path as g on i.path = g.path;
  EOQ
}
