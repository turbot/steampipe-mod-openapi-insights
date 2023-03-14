benchmark "security_scheme" {
  title       = "Security Scheme"
  description = ""

  children = [
    control.component_security_scheme_undefined,
    control.component_security_schemes_not_using_http_basic,
    control.component_security_schemes_not_using_http_digest,
    control.component_security_schemes_not_using_http_negotiate,
    control.component_security_schemes_not_using_http_unknown_scheme,
    control.component_security_scheme_not_using_oauth
  ]
}

control "component_security_scheme_undefined" {
  title       = "A security scheme on components should be defined"
  description = ""
  sql         = query.component_security_scheme_undefined.sql
}

control "component_security_schemes_not_using_http_basic" {
  title       = "A Security scheme should not use 'basic' authentication"
  description = ""
  sql         = query.component_security_schemes_not_using_http_basic.sql
}

control "component_security_schemes_not_using_http_digest" {
  title       = "A Security scheme should not use 'digest' authentication"
  description = ""
  sql         = query.component_security_schemes_not_using_http_digest.sql
}

control "component_security_schemes_not_using_http_negotiate" {
  title       = "A Security scheme should not use 'negotiate' authentication"
  description = ""
  sql         = query.component_security_schemes_not_using_http_negotiate.sql
}

control "component_security_scheme_not_using_oauth" {
  title       = "A security scheme should not use oauth 1.0 security scheme"
  description = ""
  sql         = query.component_security_scheme_not_using_oauth.sql
}

control "component_security_schemes_not_using_http_unknown_scheme" {
  title       = "Security scheme should be registered in the IANA Authentication Scheme registry"
  description = ""
  sql         = query.component_security_schemes_not_using_http_unknown_scheme.sql
}
