# 管理画面機能の実装計画

## プロジェクト概要

### 機能要件
- 全ての写真（問題）の一覧表示
- 各問題のURL（問題ページ、答えページ）の確認とコピー機能
- パスワード保護された管理画面（パスワード: `seto-admin`）
- 写真のサムネイル表示
- 名前の確認

### 技術スタック
- Rails 8.1
- daisyUI（Tableコンポーネント）
- Hotwire/Turbo
- セッションベースの認証

---

## 実装手順

### ステップ1: AdminSessionsControllerの作成

#### 1-1. コントローラー生成

```bash
bin/rails generate controller Admins::Sessions new create
```

#### 1-2. コントローラー実装

`app/controllers/admins/sessions_controller.rb`:
```ruby
class Admins::SessionsController < ApplicationController
  ADMIN_PASSWORD = "seto-admin"

  def new
  end

  def create
    if params[:password] == ADMIN_PASSWORD
      session[:admin_authenticated] = true
      redirect_to admins_root_path, notice: "管理画面にログインしました"
    else
      flash.now[:alert] = "パスワードが違います"
      render :new, status: :unprocessable_entity
    end
  end
end
```

#### 1-3. ビュー作成

`app/views/admins/sessions/new.html.erb`:
```erb
<div class="min-h-screen bg-gradient-to-br from-orange-900 to-red-900 flex items-center justify-center px-4">
  <div class="max-w-md w-full">
    <div class="text-center mb-8">
      <h1 class="text-5xl font-bold text-white mb-2">🔐</h1>
      <h2 class="text-3xl font-bold text-white">管理画面</h2>
    </div>

    <div class="card bg-base-100 shadow-2xl">
      <div class="card-body">
        <% if alert %>
          <div class="alert alert-error mb-4">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
            <span><%= alert %></span>
          </div>
        <% end %>

        <%= form_with url: admins_session_path, method: :post, local: true do |f| %>
          <div class="form-control w-full mb-6">
            <%= f.label :password, "パスワード", class: "label" %>
            <%= f.password_field :password, required: true, class: "input input-bordered input-lg w-full", placeholder: "パスワードを入力", autofocus: true %>
          </div>

          <div class="form-control mt-6">
            <%= f.submit "ログイン", class: "btn btn-primary btn-lg w-full" %>
          </div>
        <% end %>
      </div>
    </div>

    <div class="text-center mt-6">
      <%= link_to "写真をアップロード", new_photo_path, class: "link link-hover text-white" %>
    </div>
  </div>
</div>
```

---

### ステップ2: ApplicationControllerに認証メソッド追加

#### 2-1. 認証メソッドの追加

`app/controllers/application_controller.rb`に以下を追加:

```ruby
private

def require_admin_authentication
  unless session[:admin_authenticated]
    redirect_to new_admins_session_path, alert: "管理画面のパスワードを入力してください"
  end
end
```

---

### ステップ3: AdminsControllerの作成

#### 3-1. コントローラー生成

```bash
bin/rails generate controller Admins index
```

#### 3-2. コントローラー実装

`app/controllers/admins_controller.rb`:
```ruby
class AdminsController < ApplicationController
  before_action :require_admin_authentication

  def index
    @photos = Photo.order(created_at: :desc)
  end
end
```

#### 3-3. ビュー作成

`app/views/admins/index.html.erb`:
```erb
<div class="min-h-screen bg-base-200 py-8 px-4">
  <div class="max-w-7xl mx-auto">
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-4xl font-bold text-primary">管理画面</h1>
      <div class="text-sm breadcrumbs">
        <ul>
          <li><%= link_to "写真アップロード", new_photo_path, class: "link" %></li>
          <li><%= link_to "クイズ", new_session_path, class: "link" %></li>
        </ul>
      </div>
    </div>

    <% if notice %>
      <div class="alert alert-success mb-4">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span><%= notice %></span>
      </div>
    <% end %>

    <div class="stats stats-vertical lg:stats-horizontal shadow mb-8 w-full">
      <div class="stat">
        <div class="stat-title">総問題数</div>
        <div class="stat-value"><%= @photos.count %></div>
        <div class="stat-desc">登録されている写真</div>
      </div>
    </div>

    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title text-2xl mb-4">写真一覧</h2>

        <% if @photos.empty? %>
          <div class="alert alert-warning">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
            <span>まだ写真がアップロードされていません</span>
          </div>
        <% else %>
          <div class="overflow-x-auto">
            <table class="table table-zebra">
              <thead>
                <tr>
                  <th>写真</th>
                  <th>名前</th>
                  <th>問題URL</th>
                  <th>答えURL</th>
                  <th>アップロード日時</th>
                </tr>
              </thead>
              <tbody>
                <% @photos.each do |photo| %>
                  <tr>
                    <td>
                      <div class="avatar">
                        <div class="mask mask-squircle w-24 h-24">
                          <%= image_tag photo.image, class: "object-cover" %>
                        </div>
                      </div>
                    </td>
                    <td>
                      <div class="font-bold text-lg"><%= photo.name %></div>
                    </td>
                    <td>
                      <div class="flex items-center gap-2">
                        <input type="text" readonly value="<%= quiz_url(photo) %>" class="input input-bordered input-sm w-full max-w-xs" id="quiz_url_<%= photo.id %>" />
                        <button class="btn btn-sm btn-square" onclick="copyToClipboard('quiz_url_<%= photo.id %>')">
                          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                          </svg>
                        </button>
                      </div>
                    </td>
                    <td>
                      <div class="flex items-center gap-2">
                        <input type="text" readonly value="<%= quiz_answer_url(photo) %>" class="input input-bordered input-sm w-full max-w-xs" id="answer_url_<%= photo.id %>" />
                        <button class="btn btn-sm btn-square" onclick="copyToClipboard('answer_url_<%= photo.id %>')">
                          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                          </svg>
                        </button>
                      </div>
                    </td>
                    <td>
                      <div class="text-sm"><%= photo.created_at.strftime("%Y/%m/%d %H:%M") %></div>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        <% end %>
      </div>
    </div>
  </div>
</div>

<script>
  function copyToClipboard(elementId) {
    const input = document.getElementById(elementId);
    input.select();
    input.setSelectionRange(0, 99999); // For mobile devices

    navigator.clipboard.writeText(input.value).then(function() {
      // Success feedback
      const button = event.currentTarget;
      const originalHTML = button.innerHTML;
      button.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-success" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>';

      setTimeout(function() {
        button.innerHTML = originalHTML;
      }, 2000);
    }).catch(function(err) {
      console.error('Failed to copy: ', err);
    });
  }
</script>
```

---

### ステップ4: ルーティング設定

#### 4-1. ルーティングの追加

`config/routes.rb`を更新:
```ruby
Rails.application.routes.draw do
  resources :photos, only: [:new, :create]
  resource :session, only: [:new, :create]
  resources :quizzes, only: [:index, :show] do
    resource :answer, only: [:show]
  end

  namespace :admins do
    resource :session, only: [:new, :create]
    root "admins#index"
  end

  root "photos#new"

  get "up" => "rails/health#show", as: :rails_health_check
end
```

#### 4-2. ルーティング確認

```bash
bin/rails routes | grep admin
```

以下のルートが表示されることを確認:
```
new_admins_session GET  /admins/session/new(.:format)  admins/sessions#new
    admins_session POST /admins/session(.:format)      admins/sessions#create
       admins_root GET  /admins(.:format)              admins#index
```

---

## 完成後の確認事項

### 機能チェックリスト
- [ ] `/admins/session/new` でパスワード入力ページが表示される
- [ ] 間違ったパスワードでエラーメッセージが表示される
- [ ] 正しいパスワード `seto-admin` でログインできる
- [ ] `/admins` で全写真の一覧が表示される
- [ ] 写真のサムネイルが表示される
- [ ] 名前が表示される
- [ ] 問題URLが表示される
- [ ] 答えURLが表示される
- [ ] URLコピーボタンが動作する
- [ ] コピー成功時にチェックマークが表示される
- [ ] アップロード日時が表示される
- [ ] 総問題数の統計が表示される
- [ ] 認証なしではアクセスできない

### テスト手順

1. 写真をアップロード（複数枚）
2. `/admins/session/new` にアクセス
3. 間違ったパスワードでエラー確認
4. 正しいパスワード `seto-admin` でログイン
5. 管理画面で全写真が表示されることを確認
6. URLコピーボタンをクリックしてクリップボードにコピーされることを確認
7. コピーしたURLを新しいタブで開いて問題ページが表示されることを確認

---

## URL構造

### 管理画面
- `/admins/session/new` - 管理画面ログイン
- `/admins` - 管理画面一覧（要認証）

### 通常機能
- `/` - 写真アップロード
- `/session/new` - クイズログイン
- `/quizzes` - ランダムクイズ
- `/quizzes/:id` - 問題表示
- `/quizzes/:id/answer` - 答え表示

---

## デザイン仕様

### カラースキーム
- 管理画面ログイン：オレンジ×赤のグラデーション
- 管理画面一覧：ベースカラー（グレー系）

### コンポーネント
- daisyUI Table（Zebra stripe）
- daisyUI Card
- daisyUI Stats
- daisyUI Alert
- daisyUI Badge
- Avatar（写真サムネイル）

### レスポンシブ対応
- 携帯：テーブルが横スクロール
- PC：全列が表示される

---

## 今後の拡張案

### 優先度: 低
- 写真の削除機能
- 写真の編集機能
- 並び替え機能（名前順、日付順）
- 検索機能
- ページネーション

### 優先度: 中
- 一括URLコピー
- QRコード生成
- CSVエクスポート

### 優先度: 高（本番運用前に検討）
- 管理画面の権限管理強化
- ログアウト機能
