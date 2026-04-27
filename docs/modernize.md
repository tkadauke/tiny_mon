# TinyMon Modernization Roadmap — 2026

> Prepared: 2026-04-27  
> Codebase: `tkadauke/tiny_mon` — Rails 4.0 / Ruby 2.1 website acceptance-monitoring app

---

## 1. Executive Summary

- **Ruby 2.1 and Rails 4.0 are critically end-of-life** — no security patches since 2016 and 2017 respectively. Every dependency chain is frozen at matching vintage versions with dozens of known CVEs. The runtime upgrade is the mandatory first gate before anything else.
- **PhantomJS is abandoned** and `poltergeist` with it. The entire browser-emulation engine that runs health checks must be migrated to headless Chromium via `cuprite` (Capybara driver) or Playwright before the project can run on any modern system.
- **No CI pipeline exists** — the repo has zero GitHub Actions workflows, no `.travis.yml`, no automated quality gate on PRs. Every commit is currently untested in the cloud.
- **Credentials leak through step data** — IMAP passwords and Prowl API keys live in the database in YAML columns. Encryption at rest (`active_record_encryption` in Rails 7.2+) is a security prerequisite.
- **The scheduler is a busy-loop** (`loop { check_all; sleep 1 }`) with no observability, no distributed coordination, and no back-pressure. Replace with Sidekiq + `sidekiq-cron` or Solid Queue for reliable, observable background processing.

---

## 2. Current State

| Dimension | Current |
|---|---|
| **Language** | Ruby 2.1.1 (EOL April 2017) |
| **Framework** | Rails 4.0.4 (EOL June 2016) |
| **Database** | MySQL via `mysql2` 0.3.16 |
| **Browser emulation** | Capybara 2.2 + Poltergeist 1.5 → PhantomJS (EOL 2018) |
| **Auth** | Authlogic 3.4 |
| **Background jobs** | `background_lite` 0.3.2 (inline) + Resque 1.25 (production) |
| **Scheduler** | Custom busy-loop (`lib/scheduler.rb`), 1-second polling |
| **Notifications** | Email (ActionMailer) + Prowl push; no Slack/PagerDuty/webhook |
| **Asset pipeline** | Sprockets 2.x + therubyracer + libv8 3.x |
| **CSS** | Bootstrap 3.1 + Compass + Sass 3.2 |
| **Charts** | jqPlot (unmaintained since ~2013) |
| **Dev environment** | Vagrant + Berkshelf + Chef Solo |
| **CI** | None |
| **Test frameworks** | RSpec 2.14 (spec/) + Test::Unit (test/) — both present, no coverage gate |
| **Coverage** | SimpleCov 0.7 — no minimum threshold enforced |
| **Secret management** | `config/config.yml` (gitignored), IMAP passwords in DB unencrypted |
| **Containerization** | None |
| **Linting / formatting** | None |
| **Lockfile** | `Gemfile.lock` present; RubyGems source over plain HTTP |

---

## 3. Recommendations

### 3.1 Language / Runtime / Framework

**Target: Ruby 3.3.x → 3.4.x, Rails 7.2 LTS**

Rails 4 → 7 is a multi-hop migration. Attempting a single-leap upgrade will produce thousands of deprecation errors simultaneously and make bisecting failures impossible. The correct ladder:

```
Ruby  2.1  → 2.7  → 3.1  → 3.3 (current stable)
Rails 4.0  → 4.2  → 5.2  → 6.1 → 7.2
```

Each rung: update `Gemfile` ruby version constraint, run `bundle update --conservative`, run the full test suite, fix failures before proceeding. Use rbenv with a `.ruby-version` file rather than the inline `ruby '2.1.1'` Gemfile pin.

Key breaking-change checkpoints:
- **4.0 → 4.2**: `strong_parameters` replaces `attr_accessible`; `ActiveRecord#update_attributes` still works but deprecation warnings start.
- **4.2 → 5.2**: `ApplicationRecord` base class; `belongs_to` required by default; `HashWithIndifferentAccess` serialization changes.
- **5.2 → 6.1**: Zeitwerk autoloader replaces `const_missing`; all `Dir["lib/**/*.rb"]` manual requires in `config/application.rb` must be removed.
- **6.1 → 7.2**: `active_record_encryption` available; `update_attributes` fully removed (use `update`); `config.load_defaults 7.2` adds breaking defaults — enable one at a time.

Replace `therubyracer`/`libv8` (require native compilation of V8 3.x, incompatible with modern Xcode/GCC) with `mini_racer` or remove the JavaScript runtime dependency entirely once the asset pipeline is replaced with Propshaft + importmap or Vite Ruby.

### 3.2 Dependencies

**Lockfile hygiene and SCA**

The `Gemfile.lock` pins every transitive gem to 2013–2014 vintages and includes git-protocol (`git://`) remotes that GitHub disabled in 2022. Immediate actions:

1. Change the RubyGems source from `http://rubygems.org` to `https://rubygems.org`.
2. Replace `git://github.com/eightbitraptor/jqplot-rails.git` ref with a released gem or a modern charting alternative (see Architecture).
3. Remove the `:vm` group — bundling Vagrant as a gem is non-standard and drags in ancient `celluloid` pre-release versions.
4. Run `bundle audit` (gem: `bundler-audit`) in CI after every dependency change:
   ```yaml
   - run: gem install bundler-audit && bundle audit check --update
   ```
5. Enable **GitHub Dependabot** for Bundler and GitHub Actions (see Security section).
6. Pin test-only gems (`factory_bot_rails`, `rspec-rails`) to their current major versions; do not use floating `gem 'rspec'` without a version constraint.

Rename `factory_girl_rails` → `factory_bot_rails` (the gem was renamed in 2017).

### 3.3 Testing

**Target: RSpec 3.x exclusively, 80% line coverage gate, mutation testing on core logic**

The dual-framework situation (RSpec in `spec/`, Test::Unit in `test/`) creates maintenance overhead. Migrate all `test/unit/` tests to RSpec; the `rspec-rails` matchers already exist. Delete `test/` once migration is complete.

Steps:
1. Upgrade to `rspec-rails ~> 6.0` (requires Rails 5+).
2. Replace `factory_girl` with `factory_bot`.
3. Replace `mocha` with RSpec's built-in `double`/`allow`/`expect` mocks — `mocha` has not been maintained to work well with modern Ruby.
4. Add SimpleCov with a minimum threshold:
   ```ruby
   # spec/spec_helper.rb
   SimpleCov.start 'rails' do
     minimum_coverage 80
     add_filter '/spec/'
   end
   ```
5. Add **mutation testing** with `mutant` for the core health-check execution path (`Runner`, `Scheduler`, step classes). Mutation testing is especially valuable here because incorrect failure-detection logic is a silent bug:
   ```bash
   bundle exec mutant run --include lib --require runner -- 'Runner'
   ```
6. Add **integration/system specs** with `rspec-rails` system tests using the new Chromium driver (see Architecture) to cover the end-to-end step execution flow.
7. Seed a coverage badge in the README via `simplecov-lcov` + Codecov or Coveralls.

### 3.4 CI/CD

**Target: GitHub Actions with pinned SHA, matrix, OIDC, and layer caching**

There is no CI today. Create `.github/workflows/ci.yml`:

```yaml
name: CI
on:
  push:
    branches: [master]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-24.04
    strategy:
      matrix:
        ruby: ['3.3', '3.4']

    services:
      mysql:
        image: mysql:8.4
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: tiny_mon_test
        ports: ['3306:3306']
        options: --health-cmd="mysqladmin ping" --health-interval=10s

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
      - uses: ruby/setup-ruby@32110d4e311bd8996b2a82bf2a43b714ccc91777  # v1.221.0
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true
      - run: bundle exec rake db:create db:schema:load
        env:
          RAILS_ENV: test
          DATABASE_URL: mysql2://root:root@127.0.0.1/tiny_mon_test
      - run: bundle exec rspec spec
      - run: bundle exec rake test
      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02  # v4.6.2
        if: always()
        with:
          name: coverage-${{ matrix.ruby }}
          path: coverage/

  lint:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      - uses: ruby/setup-ruby@32110d4e311bd8996b2a82bf2a43b714ccc91777
        with:
          ruby-version: '3.3'
          bundler-cache: true
      - run: bundle exec rubocop --parallel
      - run: gem install bundler-audit && bundle audit check --update

  security:
    runs-on: ubuntu-24.04
    permissions:
      security-events: write
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      - uses: github/codeql-action/init@ce28f5bb42b7a9f2c824e633a3f6ee835bab6858  # v3
        with:
          languages: ruby
      - uses: github/codeql-action/analyze@ce28f5bb42b7a9f2c824e633a3f6ee835bab6858
```

Key CI practices:
- **Pin every `uses:` to a full commit SHA**, not a mutable tag — tags are not immutable and can be hijacked.
- Use **OIDC** for any cloud deployments (Heroku, AWS, GCP) instead of long-lived secrets: `permissions: id-token: write`.
- Cache the Bundler install with `bundler-cache: true` in `ruby/setup-ruby` — this typically cuts CI time by 60–80%.
- Run the Ruby version matrix to catch compatibility regressions before upgrading.

### 3.5 Architecture

**Current problems: busy-loop scheduler, inline job execution, no push alerting, no webhook receiver**

**Scheduler**: Replace the `loop { check_all; sleep 1 }` script in `lib/scheduler.rb` with **Solid Queue** (Rails 8 default, no Redis required) or **Sidekiq 7 + sidekiq-cron**. Both provide:
- Persistent job storage (no memory leak if a worker crashes)
- Web UI for monitoring job state
- Retry with exponential back-off (removes the hand-rolled `retry_times = 3` in `HealthCheck#do_check`)
- Concurrency control and job deduplication

With Sidekiq, the scheduler entry becomes:

```ruby
# config/sidekiq_cron.yml
- name: health_check_scheduler
  cron: "* * * * *"          # every minute
  class: HealthCheckWorker
  queue: default
```

**`recover_zombies`**: The zombie-recovery hack (`update_all ... next_check_at is null and last_checked_at < 1.hour.ago`) exists solely because the in-process background runner can die silently. Sidekiq's at-least-once semantics with acknowledgement make this unnecessary.

**Push vs. polling in monitored sites**: The current model is correct — TinyMon is a black-box monitor that polls external sites. No change needed here. However, the internal scheduling model should flip from polling-`due`-every-second to event-driven job enqueue at schedule time.

**Alerting channels**: The notifier abstraction (`lib/tiny_mon/notification/base.rb`) is sound. Extend it with:
- `Notification::Webhook` — POST to a URL; covers Slack, Discord, Teams, PagerDuty, OpsGenie via their inbound webhook APIs
- `Notification::PagerDuty` — native Events v2 API for proper escalation policies
- `Notification::Slack` — Slack Block Kit for rich alert messages

Do not add these as one-offs; route them all through the existing `Notifier#notify!` pattern.

**IMAP email-check step**: `Net::IMAP` with plain `login` over a cleartext connection. Fix:
1. Add `ssl: true` to `Net::IMAP.new(@server, ssl: true)`.
2. Consider replacing with a modern gem like `mail` + IMAP-IDLE for real-time triggering rather than polling all messages and deleting them.

### 3.6 Code Quality

**Target: RuboCop + ERB Lint + pre-commit hooks**

No linter or formatter is configured. Introduce in this order:

1. **RuboCop** with `rubocop-rails` and `rubocop-rspec` extensions:
   ```bash
   gem 'rubocop', '~> 1.70', require: false
   gem 'rubocop-rails', require: false
   gem 'rubocop-rspec', require: false
   ```
   Generate a baseline `.rubocop.yml` with `rubocop --auto-gen-config` then tackle `Todo` entries incrementally. Do not attempt to fix all offenses before first adoption — the `rubocop_todo` file is the on-ramp.

2. **erb-lint** for the `app/views/` ERB templates:
   ```bash
   gem 'erb_lint', require: false
   ```

3. **pre-commit hooks** via `.git/hooks/pre-commit` or the `lefthook` gem (no Python dependency unlike the `pre-commit` framework):
   ```yaml
   # lefthook.yml
   pre-commit:
     commands:
       rubocop:
         glob: '*.rb'
         run: bundle exec rubocop {staged_files}
       erb-lint:
         glob: '*.erb'
         run: bundle exec erblint {staged_files}
   ```

4. **Brakeman** (Rails SAST) as a CI step and optionally as a pre-push hook:
   ```bash
   bundle exec brakeman --no-pager -q
   ```

### 3.7 Observability

**A monitoring tool must itself be exemplary to monitor. TinyMon currently has none of its own.**

**Structured logging**: Replace `puts e.backtrace` (scattered in `HealthCheck#do_check`) and the raw `Rails.logger` calls with structured JSON logging using `semantic_logger` or the `rails_semantic_logger` gem. Every check execution event should carry fields:

```json
{
  "level": "info",
  "time": "2026-04-27T12:00:00Z",
  "health_check_id": 42,
  "health_check_name": "Login flow",
  "site": "example.com",
  "duration_ms": 1842,
  "status": "success",
  "retry_count": 0
}
```

**OpenTelemetry**: Instrument the application with `opentelemetry-sdk` + `opentelemetry-instrumentation-rails`:

```ruby
# config/initializers/opentelemetry.rb
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/rails'
require 'opentelemetry/instrumentation/active_record'
require 'opentelemetry/instrumentation/net/http'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'tiny-mon'
  c.use 'OpenTelemetry::Instrumentation::Rails'
  c.use 'OpenTelemetry::Instrumentation::ActiveRecord'
  c.use 'OpenTelemetry::Instrumentation::Net::HTTP'
end
```

Add a custom span around each health-check run:

```ruby
tracer = OpenTelemetry.tracer_provider.tracer('tiny_mon')
tracer.in_span('health_check.run',
  attributes: {
    'health_check.id' => check_run.health_check_id,
    'health_check.name' => check_run.health_check.name,
    'health_check.site' => check_run.health_check.site.url
  }
) do |span|
  runner.run!
  span.set_attribute('health_check.status', 'success')
rescue => e
  span.record_exception(e)
  span.status = OpenTelemetry::Trace::Status.error(e.message)
  raise
end
```

Export to any OTLP-compatible backend (Grafana Cloud, Honeycomb, Jaeger, Datadog).

**Metrics**: Expose Prometheus-compatible metrics via the `prometheus-client` gem at a `/metrics` endpoint (protect with HTTP Basic auth or IP allowlist):

| Metric | Type | Labels |
|---|---|---|
| `tiny_mon_check_run_total` | Counter | `site`, `status` |
| `tiny_mon_check_run_duration_seconds` | Histogram | `site` |
| `tiny_mon_health_checks_due` | Gauge | — |
| `tiny_mon_zombie_recoveries_total` | Counter | — |

**Dashboards**: Provide a Grafana dashboard JSON (commit to `config/grafana/`) showing check-run rate, p95 duration by site, failure rate over time, and scheduler lag.

**Error tracking**: Add `sentry-ruby` + `sentry-rails` for exception aggregation. Replace the `exception_notification` initializer (unmaintained since Rails 5):

```ruby
# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.1
end
```

### 3.8 Security & Supply Chain

**Critical — several issues are exploitable in the current state**

| Issue | Fix |
|---|---|
| IMAP passwords stored in plain YAML columns | Rails 7.2 `encrypts :data` on `Step` and `ConfigOption` models |
| Prowl API keys in `config_options` table | Same — column-level encryption |
| `http://` RubyGems source | Change to `https://` immediately |
| `git://` dep for jqplot-rails | Replace with released gem or remove |
| No Dependabot | Add `.github/dependabot.yml` (see below) |
| No SBOM | Add `syft` to CI: `syft . -o spdx-json > sbom.spdx.json` |
| No SAST | CodeQL via GitHub Actions (see CI section) |
| No secret scanning | Enable GitHub Secret Scanning in repo settings |
| `rescue Exception` in do_check | Catch `StandardError` only — bare `Exception` swallows `SignalException` and masks `Interrupt` |

**Dependabot config**:

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: bundler
    directory: /
    schedule:
      interval: weekly
    open-pull-requests-limit: 10
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

**Column-level encryption** (Rails 7.2+):

```ruby
class Step < ApplicationRecord
  encrypts :data   # covers all IMAP credentials, run_script payloads, etc.
end
```

Run `rails db:encryption:init` to generate the key set, store keys in credentials (`rails credentials:edit`) or an AWS KMS / HashiCorp Vault reference, never in `config/config.yml`.

### 3.9 Container / Deployment

**Target: multi-stage Dockerfile, distroless runtime image, signed with cosign**

No Dockerfile exists. Replace Vagrant + Berkshelf (Chef) with a reproducible container build:

```dockerfile
# syntax=docker/dockerfile:1.7
ARG RUBY_VERSION=3.3

# ── build stage ───────────────────────────────────────────────────────────────
FROM ruby:${RUBY_VERSION}-slim AS build
WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential libmysqlclient-dev git nodejs && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test vm deploy' && \
    bundle install --jobs 4 --retry 3

COPY . .
RUN bundle exec rake assets:precompile RAILS_ENV=production SECRET_KEY_BASE=dummy

# ── runtime stage ─────────────────────────────────────────────────────────────
FROM ruby:${RUBY_VERSION}-slim AS runtime
WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libmysqlclient21 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r appuser && useradd -r -g appuser appuser

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app
RUN chown -R appuser:appuser /app

USER appuser
ENV RAILS_ENV=production RAILS_LOG_TO_STDOUT=true
EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

Sign images with **cosign** (Sigstore) in CI:

```yaml
- uses: sigstore/cosign-installer@3454372f43399081ed03b604cb2d021dabca52bb  # v3.8.2
- run: cosign sign --yes $IMAGE_DIGEST
```

**Kubernetes / Helm**: If deploying to K8s, provide a minimal Helm chart in `chart/`. The two Procfile processes (web + worker) should be separate Deployments with independent `HorizontalPodAutoscaler` configs. The Sidekiq worker Deployment does not need ingress.

Use a `PodDisruptionBudget` with `minAvailable: 1` for the web Deployment to prevent downtime during rolling updates.

### 3.10 Developer Experience

**Target: devcontainer, one-command setup, no Vagrant required**

1. **Dev Container** (`.devcontainer/devcontainer.json`): Use the official `ruby` devcontainer feature with a `docker-compose.yml` that spins up MySQL. This works identically in GitHub Codespaces and locally in VS Code or JetBrains.

2. **Makefile or `bin/setup`**: Replace the manual multi-step setup in README with:
   ```bash
   bin/setup   # installs deps, creates DB, seeds, checks system deps
   bin/dev     # wraps foreman with .env loaded
   ```

3. Replace `script/scheduler` with a Procfile entry managed by `foreman` (already in Procfile for web). Use `overmind` locally for process restart without full restart.

4. Use **dotenv** (`dotenv-rails`) to load `.env.development.local` instead of `config/config.yml`, which requires manual copying and is not self-documenting. Provide `.env.example` committed to the repo.

5. **CLAUDE.md** already exists (added separately) — keep it updated as the tech stack evolves; it is the primary orientation document for AI coding assistants.

6. Generate API documentation with `yard` for the step extension points (`Step`, `Notification::Base`) — these are the two primary extension seams and are currently undocumented.

### 3.11 AI / Agent Readiness

**Current state: CLAUDE.md is present and accurate — this is the right foundation.**

The `CLAUDE.md` correctly warns about EOL components, describes the step extension pattern, and gives an incremental upgrade ladder. Additional improvements:

1. **AGENTS.md** (future): As the codebase modernizes, add an `AGENTS.md` at root documenting the agentic workflow conventions: which tests must pass before a PR, how to run linting, where secrets live, what's off-limits (production DB credentials, etc.).

2. **Code conventions**: Add a `.editorconfig` to enforce consistent indentation (the codebase mixes tabs and spaces across ERB/Ruby files), and a `.rubocop.yml` with `AllCops.NewCops: enable` so agents generate consistent style.

3. **Test-driven agent instructions**: In CLAUDE.md, add explicit instruction that any code change must be accompanied by a spec. Agents without a passing test suite as a gate will produce unreviewable PRs in a codebase this size.

4. **Semantic versioning**: Adopt SemVer and tag releases. Agents making dependency bumps should be able to check the version to know what's changed.

5. **Architecture Decision Records**: Add `docs/adr/` with ADRs for non-obvious decisions (why Resque vs. Sidekiq, why IMAP polling vs. SMTP hook, why dual test suites). ADRs give agents the context to avoid re-litigating settled choices.

---

## 4. Prioritized Roadmap

| Priority | Item | Effort | Impact |
|---|---|---|---|
| **P0** | Switch RubyGems source to HTTPS; patch `git://` deps | < 1 hour | Critical — security |
| **P0** | Add GitHub Actions CI (test matrix, bundler-audit) | 1 day | High — no safety net exists |
| **P0** | Ruby 2.1 → 2.7 (first hop) | 3–5 days | Critical — unblocks all else |
| **P0** | Replace `rescue Exception` with `rescue StandardError` in `do_check` | 30 min | High — masks crashes |
| **P0** | Enable GitHub Secret Scanning + Dependabot | 30 min | Critical — free, immediate |
| **P1** | Ruby 2.7 → 3.1 → 3.3 | 2–3 days per hop | High |
| **P1** | Rails 4.0 → 4.2 → 5.2 | 1–2 weeks per hop | High |
| **P1** | Replace PhantomJS/Poltergeist with Cuprite (after Rails ≥ 5) | 3–5 days | High — PhantomJS is a security liability |
| **P1** | Add RuboCop + Brakeman to CI | 1 day | Medium |
| **P1** | Add structured logging (`rails_semantic_logger`) | 1 day | Medium |
| **P1** | Add Sentry error tracking | Half day | High |
| **P1** | Migrate Test::Unit tests to RSpec; enforce 80% coverage | 3–5 days | Medium |
| **P1** | Replace `background_lite`/Resque scheduler with Sidekiq + sidekiq-cron | 3–5 days | High — reliability |
| **P1** | Write Dockerfile (multi-stage, non-root) | 1–2 days | Medium |
| **P2** | Rails 5.2 → 6.1 → 7.2 | 2+ weeks | High (unlocks encryption) |
| **P2** | Column-level encryption for Step#data and ConfigOption#value | 1–2 days after Rails 7 | Critical — was blocked on Rails |
| **P2** | OpenTelemetry instrumentation + Prometheus metrics endpoint | 2–3 days | Medium |
| **P2** | Add Webhook + Slack notifier channels | 2 days | Medium |
| **P2** | Dev Container + bin/setup + dotenv | 1–2 days | Medium |
| **P2** | Image signing with cosign | Half day | Low–Medium |
| **P2** | Grafana dashboard JSON | 1 day | Low |
| **P2** | YARD documentation for step and notifier extension points | 1 day | Low |

---

## 5. Risks & Non-Goals

### Risks

**Test coverage is thin in places that matter most** — the step execution path (`Runner`, each step class) has unit specs but no integration tests against a real (or stubbed) HTTP server. Before touching the browser-driver layer, add `webmock` or `vcr` stubs and a contract test so regressions in step execution are caught immediately.

**IMAP credential exposure**: Until column-level encryption lands (Rails 7+), any DB backup or SQL injection exposes IMAP passwords for monitored systems in plaintext. The `rescue Exception` suppressor means a failed step can silently leave credentials in stack traces that get written to `check_runs.log`. Fix the rescue scope in P0.

**Large migration gap**: Going from Rails 4.0 to 7.2 is a ~4-year jump. Intermediate rung gems (e.g., `authlogic 3.x`) may not have versions compatible with every intermediate Rails version. Plan for Authlogic to be replaced with Devise or Rodauth during the Rails 6 → 7 hop, as Authlogic's Rails 7 support is community-maintained with gaps.

**jqPlot is truly abandoned**: The jqplot-rails dep is fetched from a git remote with no version tag; the upstream library has not had a release since 2013. Migrating to Chart.js (via `chartkick` gem) or Recharts should happen no later than the Rails 6 migration since the Sprockets 2.x pipeline that serves jqPlot will not work under Rails 7.

### Non-Goals

- **Replacing MySQL with PostgreSQL**: While PostgreSQL has better Rails ecosystem support (native UUID, jsonb columns, full-text search), the schema is straightforward MySQL and migration is not worth the disruption. Stay on MySQL 8.x (upgrade the server, not the adapter).
- **Microservices decomposition**: The app is small and cohesive. Splitting the scheduler, web, and worker into separate services adds operational overhead without benefit at this scale. Keep the Procfile-based monolith.
- **Server-Side Rendering / React frontend**: The ERB/HAML views work. Replace jqPlot for charts but do not rewrite the frontend in a JS framework — it would be a complete rewrite with no net-new user value.
- **Full HAML → ERB migration**: Both templating languages are present. Do not spend time on a mechanical HAML → ERB conversion; standardize on ERB for new views only.
- **SMS notifications via Twilio**: The README lists this as missing. It should be implemented via the Webhook notifier (Twilio has a webhook-compatible API) rather than a bespoke SMS driver.
