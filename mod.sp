// Benchmarks and controls for specific services should override the "service" tag
locals {
  openapi_insights_common_tags = {
    category = "Compliance"
    plugin   = "openapi"
    service  = "OpenAPI"
  }
}

mod "openapi_insights" {
  # Hub metadata
  title         = "OpenAPI Insights"
  description   = "Run individual configuration, compliance and security controls for OpenAPI specifications."
  color         = "#2483C0"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/openapi-compliance.svg"
  categories    = ["compliance", "iac", "security", "openapi"]

  opengraph {
    title       = "Steampipe Mod for OpenAPI Insights"
    description = "Run individual configuration, compliance and security controls for OpenAPI specifications."
    image       = "/images/mods/turbot/openapi-compliance-social-graphic.png"
  }
}
