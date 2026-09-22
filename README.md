# discourse-modifications

Site-specific customisations for RpNation

## Site setting overrides

Desired site setting values are declared in `config/site_setting_overrides.yml` and applied explicitly with a rake task. Settings are never applied automatically on boot.

### Applying overrides

```bash
rake rpn:apply_settings
```

Each setting is applied via `SiteSetting.set_and_log`, which skips no-ops and writes an audit log entry for every change. The task exits with code `1` if any setting name is unrecognised.

### `config/site_setting_overrides.yml` format

```yaml
# bool
login_required: true

# integer
max_post_length: 500000

# list types — pipe-separated string, not a YAML list
permalink_normalizations: 'pattern1|pattern2'
```

`upload`, `uploaded_image_list`, and `objects` type settings cannot be expressed in YAML and must be configured through the admin UI.

### Pulling overrides from a live site

```bash
script/pull_settings --url https://community.example.com --api-key <key>
```

Fetches all settings that differ from their defaults via the Discourse admin API, skips secrets and unsupported types, and overwrites `config/site_setting_overrides.yml`. Use `--dry-run` to preview without writing.

```
Options:
  -u, --url URL       Base URL of the Discourse site
  -k, --api-key KEY   Admin API key
  -o, --output PATH   Output file (default: config/site_setting_overrides.yml)
      --dry-run       Print settings without writing the file
```
