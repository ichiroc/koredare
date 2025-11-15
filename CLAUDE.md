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

## Rails設計プラクティス

このプロジェクトでは以下のRails設計原則に従います：

### RESTful設計
- 基本的にREST 7アクション（index, show, new, create, edit, update, destroy）のみを使用
- カスタムアクションは最小限に抑える
- リソース指向のURL設計を重視

### コントローラーの責務分離
- 認証機能は専用のSessionsControllerで管理
- 各コントローラーは単一の責務を持つ
- before_actionで共通処理を整理

### ネストしたリソース設計
- 親子関係のあるリソースは適切にネスト
- 単一子リソース（singular resource）の活用
  - 例: `resources :quizzes do resource :answer end`
  - URL: `/quizzes/:quiz_id/answer`（複数形ではなく単数形）
  - 1つのクイズに対して答えは1つなので単数形リソースを使用

### ルーティング設計
- `only`オプションで必要なアクションのみ公開
- リソース間の関係を明確に表現
- Rails wayに従ったRESTfulなURL構造

### 実装の進め方
- 機能ごとに段階的に実装する（モデル→コントローラー→ビューの順ではない）
- 各フェーズで完結した機能を作り、動作確認してから次へ進む
- 例：「写真アップロード機能」を完成させてから「パスワード認証機能」に進む
- 各フェーズの終わりには必ず動作確認を行い、期待通りに動くことを確認する
- 実装計画は詳細に具体化し、PLAN.mdなどのドキュメントとして残す
