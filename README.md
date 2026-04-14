# NoParking

**An open-source, self-hostable parking enforcement platform for municipalities.**

NoParking lets residents report parking violations from their phone (photo, GPS,
category, notes), routes those reports to enforcement officers, and gives
managers and site administrators the tools to run the whole operation.

> ⚠️ **Under active development.** This project is in an early, rapidly-changing
> state. Schemas, routes, and features are still being shaped and **will**
> change without notice. It is not yet recommended for production use. Star the
> repo to follow along.

## Live demo

A running demo is available at **[noparking.hackjc.org](https://noparking.hackjc.org)**.

Feel free to create a test account and report an imaginary violation. The demo
database is reset periodically without warning, so don't store anything you
care about there.

## What's in the box today

- **Residents** can register (email *or* phone), report a violation via a
  3-step mobile-first wizard (photo → map pin → details), and review their
  past reports.
- **Site admins** have a dedicated dashboard at `/admin` for managing
  violation categories and manager accounts, plus anonymized activity stats.
- **Enforcement officers** and **managers** are modeled in the role system
  but their full workflows (dispatch, schedules, KPIs) are not built yet —
  see [NOTES.md](./NOTES.md) for the roadmap.

## Tech stack

- Rails 8.1 · Ruby 3.4
- SQLite (Solid Cache / Queue / Cable)
- Hotwire (Turbo + Stimulus) via importmap — no Node/bundler required
- Tailwind CSS 4
- Active Storage for photo uploads
- Leaflet + OpenStreetMap for the map / reverse geocoding
- Kamal for deployment

## Getting started

Prerequisites: Ruby 3.4.5 and a recent SQLite3.

```bash
bundle install
bin/rails db:prepare    # creates and seeds the database
bin/dev                 # starts Rails + tailwindcss watcher
```

The app will be available at <http://localhost:3000>.

### Create a site admin

Admin accounts cannot be self-registered. Create one via the Rake task:

```bash
EMAIL=you@example.com PASSWORD='your long passphrase' bin/rails admin:create
```

Or run `bin/rails admin:create` to be prompted interactively (password input
is hidden). The task promotes an existing user if the email already exists.
Sign in and you'll land on `/admin`.

## Running the tests

```bash
bin/rails test
```

## Deployment

Deployment is handled by [Kamal](https://kamal-deploy.org). See
`config/deploy.yml` for the template. You'll need to:

1. Set `image:` to `<your-dockerhub-user>/<app-name>`.
2. Point `servers.web` and `proxy.host` to your infrastructure.
3. Provide `KAMAL_REGISTRY_PASSWORD` and `RAILS_MASTER_KEY` in `.kamal/secrets`.
4. `bin/kamal setup` for the first deploy; `bin/kamal deploy` thereafter.

## Rebranding

The app name is a single i18n key — `app.name` in
[`config/locales/en.yml`](./config/locales/en.yml). Change that one string and
the navbar, page titles, PWA manifest, and flash messages all follow.

## Contributing

Because things are moving fast, please open an issue to discuss larger changes
before sending a pull request. Small fixes and tests are always welcome.

## License

TBD. See [NOTES.md](./NOTES.md) for project intent.
