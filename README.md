# OpenAPI Insights Mod for Steampipe

An OpenAPI tool that has 20+ checks covering best practices on OpenAPI specification files.

## Getting started

### Installation

Download and install Steampipe (https://steampipe.io/downloads).

Or use Brew:

```sh
brew tap turbot/tap
brew install steampipe
```

Install the OpenAPI plugin with [Steampipe](https://steampipe.io):

```sh
steampipe plugin install openapi
```

Clone:

```sh
git clone https://github.com/turbot/steampipe-mod-openapi-insights.git
cd steampipe-mod-openapi-insights
```

### Usage

Start your dashboard server to get started:

```sh
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser window at http://localhost:9194. From here, you can view dashboards and reports, and run benchmarks by selecting one or searching for a specific one.

Instead of running benchmarks in a dashboard, you can also run them within your terminal with the `steampipe check` command:

Run all benchmarks:

```sh
steampipe check all
```

Run a single benchmark:

```sh
steampipe check benchmark.response_best_practices
```

Run a specific control:

```sh
steampipe check control.components_response_definition_unused
```

Different output formats are also available, for more information please see [Output Formats](https://steampipe.io/docs/reference/cli/check#output-formats).

### Credentials

No credentials are required.

### Configuration

No extra configuration is required.

## Contributing

If you have an idea for additional dashboards or controls, or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing.

- **[Join #steampipe on Slack →](https://turbot.com/community/join)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-openapi-insights/blob/main/LICENSE).

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [OpenAPI Insights Mod](https://github.com/turbot/steampipe-mod-openapi-insights/labels/help%20wanted)
