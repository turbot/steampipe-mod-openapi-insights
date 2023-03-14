benchmark "server" {
  title       = "Server"
  description = "Servers Best Practices."

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
  sql         = query.server_undefined.sql
}

control "server_uses_https" {
  title       = "Global servers' URL should use HTTPS protocol"
  description = "Global server object URL should use 'https' protocol instead of 'http'."
  severity    = "medium"
  sql         = query.server_uses_https.sql
}

control "path_server_uses_https" {
  title       = "Path Server Object url should use 'HTTPS' protocol"
  description = "The property 'url' in the Path Server Object should only allow 'HTTPS' protocols to ensure an encrypted connection."
  severity    = "medium"
  sql         = query.path_server_uses_https.sql
}
