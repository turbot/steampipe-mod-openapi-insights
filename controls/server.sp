benchmark "server" {
  title       = "Server"
  description = ""

  children = [
     control.server_undefined,
    control.path_server_uses_https
  ]
}

control "server_undefined" {
  title       = "Servers array should have at least one server defined"
  description = ""
  sql         = query.server_undefined.sql
}

control "path_server_uses_https" {
  title       = "Path Server Object url should use 'HTTPS' protocol"
  description = ""
  sql         = query.path_server_uses_https.sql
}
