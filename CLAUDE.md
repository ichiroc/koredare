# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails 8.1 application using modern frontend stack with Hotwire (Turbo + Stimulus), Tailwind CSS v4, and esbuild. Uses SQLite3 for database with Solid Cache, Queue, and Cable adapters. Deployment configured with Kamal and Docker.

## Ruby & Node Versions

- Ruby: 3.4.5
- Node: 20.19.5

## Development Commands

### Initial Setup
```bash
bin/setup
```

### Starting Development Server
```bash
bin/dev  # Starts Rails server, JS watch, and CSS watch via Procfile.dev
```

Individual processes:
- Rails server: `bin/rails server` (with RUBY_DEBUG_OPEN=true)
- JS bundling: `yarn build --watch`
- CSS bundling: `bun run build:css --watch`

### Asset Building
```bash
# JavaScript (esbuild)
yarn build

# CSS (Tailwind v4)
bun run build:css
```

### Database
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### Testing
```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/controllers/some_controller_test.rb

# Run system tests
bin/rails test:system
```

### Code Quality & Security
```bash
# RuboCop (Rails Omakase styling)
bin/rubocop

# Brakeman (security scanning)
bin/brakeman

# Bundler audit (gem vulnerability checking)
bin/bundler-audit

# Run all checks (used in CI)
bin/ci
```

## Architecture

### Frontend Architecture

- **Hotwire stack**: Turbo for SPA-like navigation, Stimulus for JavaScript sprinkles
- **JavaScript**: Bundled with esbuild from `app/javascript/`
  - Entry point: `app/javascript/application.js`
  - Stimulus controllers in `app/javascript/controllers/`
  - Output to `app/assets/builds/`
- **CSS**: Tailwind CSS v4 with standalone CLI
  - Source: `app/assets/stylesheets/application.tailwind.css`
  - Output to `app/assets/builds/application.css`
- **Asset pipeline**: Propshaft (modern Rails asset pipeline)

### Backend Architecture

- **Database**: SQLite3 with multiple databases in production:
  - Primary: application data
  - Cache: Solid Cache (database-backed caching)
  - Queue: Solid Queue (Active Job backend)
  - Cable: Solid Cable (Action Cable backend)
- **Deployment**: Kamal with Docker, Thruster for asset optimization

### Directory Structure

- `app/javascript/`: JavaScript source files (Stimulus controllers, application.js)
- `app/assets/builds/`: Compiled JavaScript and CSS output
- `app/assets/stylesheets/`: Tailwind CSS source
- `storage/`: SQLite database files (development, test, production)
- `bin/`: Executable scripts for common tasks

## Deployment

Uses Kamal for deployment. Configuration in:
- `.kamal/`: Kamal deployment configs
- `config/deploy.yml`: Main deployment configuration
- `Dockerfile`: Docker container definition
