# discourse-rpn

Site-specific customisations for RpNation

## Topic owner bumps

Topic owners can bump their own topic with a **Bump** button in the topic footer, instead of posting "bump" replies. A bump is a small action post ("Bumped 2 hours ago") that moves the topic to the top of Latest without notifying anyone or changing the last poster.

- **Per category:** enable it with "Allow topic owners to bump their topics" on the category's Settings tab (custom field `topic_owner_bump_enabled`). Subcategories inherit it from any ancestor, and can't opt out while an ancestor is opted in.
- **Cooldown:** `topic_owner_bump_cooldown_minutes` (default 1440 = 1 day, max 43200 = 30 days) counted from the topic's latest reply or bump, so replying also restarts the cooldown.
- **Who:** only the topic owner, and only while they could reply. PMs, closed, archived and unlisted topics can't be bumped.
- **API:** `POST /discourse-rpn/topics/:topic_id/bump`.

## Locked minimum watch categories

Users can't lower their notification level below **watching first post** for the categories in the `locked_min_watch_categories` site setting. They can still raise it to **watching**.

- **Assigning the level:** the setting only locks. Add the same categories to `default_categories_watching_first_post` to give the level to new signups, and use "apply to existing users" on that setting for everyone already on the site. New users are also given the minimum level on creation, even if the category isn't in the defaults.
- **Category bell:** `POST /category/:id/notifications` returns 403 for a level below the minimum. The menu hides those levels on a locked category.
- **Preferences:** `PUT /u/:username` returns 403 if a locked category is placed in the tracked, muted or regular lists. A locked category left out of the watched lists is put back at watching first post.
- **Unwatch link in emails:** the row is not destroyed, so the user stays watching. The confirmation page still reports success.
- **Not covered:** bulk writers that skip model callbacks can still remove a row, namely group default notification levels and removing a category from a `default_categories_*` setting. It is put back the next time the user saves their category preferences. Avoid group default levels for locked categories.
- **Turning it off:** clearing the setting or disabling the plugin stops enforcement. Existing rows are left as they are.

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
