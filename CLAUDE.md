# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TinyMon is a Rails web application for website acceptance monitoring. It periodically runs scripted health checks against websites, emulating a real user by composing browser steps (visit, click, fill in forms, check content, take screenshots, check email inboxes, etc.). Results are surfaced through a web UI with run history, duration graphs, log output, and notifications (email and Prowl). Health checks are grouped under accounts and sites, can be created from reusable templates, and are executed by a background scheduler driven by Capybara + Poltergeist (PhantomJS) and, in production, Resque workers.

## Tech Stack

- Ruby 2.1.1
- Rails 4.0.x
- MySQL (via `mysql2`)
- Capybara + Poltergeist (PhantomJS) for browser-driven health checks
- Authlogic for authentication; `scrypt` for password hashing
- Resque (production) for background jobs; `background_lite` abstraction
- RSpec + factory_girl + mocha + simplecov for tests
- Sass / Compass / Bootstrap (`bootstrap-sass`) for styling; jQuery + jQuery UI; jqplot for charts
- Spring + Guard (guard-rspec) for development
- Foreman (Procfile) for process management; Capistrano for deploys; Vagrant + Berkshelf for VM setup
- I18n: English and German (`rails-i18n`)

## Repository Structure

- `app/` - Standard Rails layout
  - `models/` - Domain: `Account`, `Site`, `HealthCheck`, `HealthCheckTemplate`, `CheckRun`, `Step`, `Screenshot`, `Deployment`, `User`, etc.
  - `controllers/` - Resourceful controllers; admin controllers under `controllers/admin/`
  - `steps/` - Health-check step types (`visit_step.rb`, `click_link_step.rb`, `fill_in_step.rb`, `check_content_step.rb`, `check_email_step.rb`, `take_screenshot_step.rb`, `run_script_step.rb`, etc.)
  - `views/`, `helpers/`, `mailers/`, `assets/`
- `config/` - Rails config (`application.rb`, `routes.rb`, `environments/`, `initializers/`, `locales/`, `deployments/`, `background.yml`, `options.yml`)
- `db/` - `migrate/`, `schema.rb`, `seeds.rb`
- `lib/`
  - `tiny_mon/` - App-internal modules (`config.rb`, `notifier.rb`, `comment_notifier.rb`, `notification/`, `version.rb`)
  - `runner.rb`, `scheduler.rb`, `email_checker.rb`, `session.rb`, `check_failed.rb`, `has_properties.rb`
  - `core_ext/`, `rails_ext/` - Monkey-patches loaded eagerly at boot
  - `tasks/` - `assets.rake`, `configuration.rake`
  - `generators/`
- `spec/` - RSpec tests (`models/`, `controllers/`, `helpers/`, `mailers/`, `lib/`, `steps/`, `factories/`, `support/`, `fixtures/`)
- `test/` - Legacy / minimal Test::Unit directory (RSpec is the primary suite)
- `script/` - `scheduler` (background check runner), `background_queue`, `rails`
- `bin/` - Standard binstubs (`rails`, `rake`, `rspec`, `bundle`, `foreman`, `setup`, `spring`)
- `doc/` - Project notes
- `public/` - Static assets
- `Procfile`, `Berksfile`, `Vagrantfile`, `Guardfile` - Process / VM / dev tooling

## Common Commands

Install dependencies and prepare the database:

```
bundle install
rake db:setup:all
```

Run the dev server (Foreman uses `Procfile`):

```
bin/setup            # bundle install + writes .env and .foreman
bin/foreman start    # boots web + worker
# or directly:
bundle exec rails server
```

Run the background check scheduler:

```
RAILS_ENV=production script/scheduler
```

Production server start (per README):

```
rails server -e production
```

Run the test suite:

```
bundle exec rspec                # all specs
bin/rspec spec/models/health_check_spec.rb   # one file
spring rspec spec/models         # via Spring (used by Guard)
bundle exec guard                # auto-run on file changes
```

Asset / configuration tasks live in `lib/tasks/assets.rake` and `lib/tasks/configuration.rake`; list available tasks with `bundle exec rake -T`.

External binaries required at runtime: `phantomjs` (browser engine for Poltergeist) and `pngcrush` (used by screenshot pipeline).

## Architecture & Conventions

- Standard Rails 4 MVC. Routes in `config/routes.rb` are wrapped in a `scope "(:locale)", :locale => /en|de/` block - most paths are locale-prefixed.
- Domain hierarchy: `Account` -> `Site` -> `HealthCheck` -> `Step`s. A `HealthCheck` produces `CheckRun`s, which can have `Comment`s, `Screenshot`s, and `ScreenshotComparison`s. `HealthCheckTemplate` provides reusable, parameterized check definitions via `HealthCheckTemplateStep` and `HealthCheckTemplateVariable`.
- Step plugin pattern: each browser action is a class under `app/steps/` (e.g. `VisitStep`, `ClickLinkStep`, `FillInStep`, `CheckContentStep`, `CheckEmailStep`, `TakeScreenshotStep`). Step data is persisted as serialized YAML on `Step` / `HealthCheckTemplateStep`.
- Health-check execution is implemented in `lib/runner.rb` and orchestrated by `lib/scheduler.rb`; Capybara + Poltergeist (PhantomJS) drives the browser. Email-step support uses `lib/email_checker.rb` (IMAP).
- `config/application.rb` eagerly requires every file in `lib/*.rb`, `lib/core_ext/**/*.rb`, `lib/rails_ext/**/*.rb`, and `lib/tiny_mon/**/*.rb` at boot. New library files in those locations are loaded automatically; do not rely on Rails autoloading there.
- Authentication via Authlogic (`UserSession`, `User`); password hashing via `scrypt`. Admin section is namespaced under `/admin` with controllers in `app/controllers/admin/`.
- Background jobs: `background_lite` is the abstraction used in app code; in production it is backed by Resque (`group :production`). Configuration lives in `config/background.yml`.
- Pagination uses `will_paginate` (with `bootstrap-will_paginate` styling). Lists that need ordering use `acts_as_list`. Slugs use `permalink_fu`.
- I18n: locale files under `config/locales/`. The `i18n_tools` gem and `.i18nignore_unused` are present for translation maintenance.
- Deploy configuration is split across `config/deployments/{ci,development}` plus Capistrano; `config/deployments/production` and `config/deploy*` are gitignored.

## Testing

- Primary framework: RSpec (`bundle exec rspec`). Configuration in `.rspec` (`--color`) and `spec/spec_helper.rb`.
- `spec_helper.rb` requires `simplecov` (coverage), `rspec/rails`, includes `FactoryGirl::Syntax::Methods`, reloads factories before each suite, and uses transactional fixtures.
- Tests are organized by Rails layer: `spec/models`, `spec/controllers`, `spec/helpers`, `spec/mailers`, `spec/steps`, `spec/lib`. Factories live in `spec/factories/`, shared helpers in `spec/support/`.
- `mocha` is also available for mocking (note the `#removeme` comment in the Gemfile - prefer rspec-mocks for new code).
- `bin/rspec` and `spring rspec` (used by `Guardfile`) are the fast paths during development.
- A small legacy `test/` directory exists but RSpec is the canonical suite.

## Notes / Gotchas

- Ruby 2.1.1 and Rails 4.0.x are old; gems are pinned accordingly. Do not casually upgrade Rails, Rake (`10.1.1`), `authlogic` (`~> 3.4.0`), or `background_lite` (`0.3.2`) without coordinated changes.
- `config/application.rb` defines `returning` on `Object` and sets a top-level `RAILS_ENV` constant - both are intentional legacy shims; keep them in mind when reading code that uses `returning(obj) { ... }`.
- PhantomJS is required for the browser engine. Per the README, upgrading from 0.1.x means migrating YAML columns (`steps.data`, `health_check_template_steps.step_data_hash`, `config_options.value`, `check_runs.log`) to UTF-8.
- The Gemfile sources from `http://rubygems.org` (HTTP, not HTTPS) and pulls some gems from `git://` URLs (`jqplot-rails`, `vagrant`); modern bundler / git may need configuration to fetch them.
- `config/database.yml`, `config/config.yml`, and `config/deploy*` are gitignored - expect to create them locally before booting the app.
