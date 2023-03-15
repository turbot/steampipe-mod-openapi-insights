benchmark "server" {
  title       = "Server Best Practices"
  description = "Best practices for servers."

  children = [
    control.server_undefined,
    control.server_uses_https,
    control.path_server_uses_https
  ]
}

control "server_undefined" {
  title       = "Servers array should have at least one server defined"
  description = "The Servers array should have at least one server defined. If not, the default value would be a Server Object with a URL value of '/'."
  severity    = "none"
  sql         = <<-EOQ
    with server_count as (
      select
        path,
        count(*)
      from
        openapi_server
      group by
        path
    )
    select
      i.title as resource,
      case
        when s.path is null or s.count < 1 then 'alarm'
        else 'ok'
      end as status,
      case
        when s.path is null or s.count < 1 then i.title || ' server array is empty.'
        else i.title || ' has ' || s.count || ' server(s) defined.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join server_count as s on i.path = s.path;
  EOQ
}

control "server_uses_https" {
  title       = "Global servers' URL should use HTTPS protocol"
  description = "Global server object URL should use 'https' protocol instead of 'http'."
  severity    = "medium"
  sql         = <<-EOQ
    with server_not_using_https_protocol as (
      select
        path,
        array_agg(url) as urls
      from
        openapi_server
      where
        url not like 'https:%'
      group by
        path
    )
    select
      i.title as resource,
      case
        when s.path is null then 'ok'
        else 'alarm'
      end as status,
      case
        when s.path is null then i.title || ' server urls uses ''HTTPS'' protocol.'
        else i.title || ' has following servers doesn''t use ''HTTPS'' protocol: ' || array_to_string(s.urls, ', ') || '.'
      end as reason,
      i.path
    from
      openapi_info as i
      left join server_not_using_https_protocol as s on i.path = s.path;
  EOQ
}

control "path_server_uses_https" {
  title       = "Path Server Object url should use 'HTTPS' protocol"
  description = "The property 'url' in the Path Server Object should only allow 'HTTPS' protocols to ensure an encrypted connection."
  severity    = "medium"
  sql         = <<-EOQ
    select
      api_path || ' : ' || (path_server ->> 'url') as resource,
      case
        when path_server ->> 'url' like 'https:%' then 'ok'
        else 'alarm'
      end as status,
      case
        when path_server ->> 'url' like 'https:%' then 'Path server url uses ''HTTPS'' protocol.'
        else 'Path server url not uses ''HTTPS'' protocol.'
      end as reason,
      path
    from
      openapi_path,
      jsonb_array_elements(servers) as path_server;
  EOQ
}
