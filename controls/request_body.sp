benchmark "request_body" {
  title       = "Request Body"
  description = "Request Bodies Best Practices."

  children = [
    control.component_request_body_definition_unused,
    control.request_body_object_with_no_incorrect_media_type
  ]
}

control "component_request_body_definition_unused" {
  title       = "Component request body definition should be used as reference somewhere"
  description = "Components request bodies definitions should be referenced or removed from Open API definition."
  severity    = "none"
  sql         = query.component_request_body_definition_unused.sql
}

control "request_body_object_with_no_incorrect_media_type" {
  title       = "Request body content type should be 'multipart' or 'application/x-www-form-urlencoded' when 'encoding' is set"
  description = "The field 'content' of the request body object should be set to 'multipart' or 'application/x-www-form-urlencoded' when field 'encoding' is set."
  severity    = "none"
  sql         = query.request_body_object_with_no_incorrect_media_type.sql
}
