benchmark "security_scheme" {
  title       = "Security Scheme"
  description = ""

  children = [
    control.component_security_scheme_undefined
  ]
}

control "component_security_scheme_undefined" {
  title       = "A security scheme on components should be defined"
  description = ""
  sql         = query.component_security_scheme_undefined.sql
}
