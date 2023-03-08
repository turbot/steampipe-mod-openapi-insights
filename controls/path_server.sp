benchmark "path" {
  title       = "Path"
  description = ""

  children = [
    control.path_server_uses_https
  ]
}

control "path_server_uses_https" {
  title       = "Path Server Object url should use 'HTTPS' protocol"
  description = ""
  sql         = query.path_server_uses_https.sql
}
