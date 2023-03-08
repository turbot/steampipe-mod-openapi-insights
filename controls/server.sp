benchmark "server" {
  title       = "Server"
  description = ""

  children = [
    control.server_undefined
  ]
}

control "server_undefined" {
  title       = "Servers array should have at least one server defined"
  description = ""
  sql         = query.server_undefined.sql
}
