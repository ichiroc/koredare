# 写真クイズアプリケーション実装計画

## プロジェクト概要

### 機能要件
- 誰でも自分の写真を名前と一緒にアップロードできる
- 携帯とパソコン両方に対応
- 一度に1つの画像をアップロード
- パスワード保護されたクイズ表示機能（パスワード: `seto-gasshuku-10`）
- プロジェクターでの投影を想定した大画面デザイン
- 問題ページ（写真のみ）→ 答えボタン → 答えページ（写真+名前）
- ランダムな順序でクイズを表示
- 次の問題へボタンで次のランダムなクイズへ

### 技術スタック
- Ruby on Rails 8.1
- Active Storage（画像管理）
- Hotwire/Turbo（SPA風遷移）
- Tailwind CSS v4（レスポンシブデザイン）
- SQLite3
- セッション（パスワード認証状態保持）

### アーキテクチャ設計
- RESTful設計（REST 7アクション基本）
- コントローラー責務分離
- ネストした単一子リソース（answers は quizzes の子リソース）

---

## フェーズ0: CLAUDE.md更新

### 目的
今回の実装で学んだRails設計プラクティスをCLAUDE.mdに記録

### 実装内容

CLAUDE.mdに以下のセクションを追加：

```markdown
## Rails設計プラクティス

このプロジェクトでは以下のRails設計原則に従います：

### RESTful設計
- 基本的にREST 7アクション（index, show, new, create, edit, update, destroy）のみを使用
- カスタムアクションは最小限に抑える
- リソース指向のURL設計

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
```

### 確認手順
- CLAUDE.mdを開いて内容を確認

---

## フェーズ1: 写真アップロード機能

### 目的
ユーザーが自分の写真を名前と一緒にアップロードできる機能

### 実装手順

#### 1. Active Storageのインストール

```bash
bin/rails active_storage:install
bin/rails db:migrate
```

#### 2. Photoモデルの作成

```bash
bin/rails generate model Photo name:string
bin/rails db:migrate
```

モデルファイル編集（`app/models/photo.rb`）:
```ruby
class Photo < ApplicationRecord
  has_one_attached :image

  validates :name, presence: true
  validates :image, presence: true

  def self.random
    order("RANDOM()").first
  end
end
```

#### 3. PhotosControllerの作成

```bash
bin/rails generate controller Photos new create
```

コントローラー実装（`app/controllers/photos_controller.rb`）:
```ruby
class PhotosController < ApplicationController
  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new(photo_params)

    if @photo.save
      redirect_to new_photo_path, notice: "写真をアップロードしました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def photo_params
    params.require(:photo).permit(:name, :image)
  end
end
```

#### 4. ビューの作成

`app/views/photos/new.html.erb`:
```erb
<div class="min-h-screen bg-gray-50 py-8 px-4">
  <div class="max-w-2xl mx-auto">
    <h1 class="text-3xl font-bold text-center mb-8">写真をアップロード</h1>

    <% if notice %>
      <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
        <%= notice %>
      </div>
    <% end %>

    <%= form_with model: @photo, local: true, class: "bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4" do |f| %>
      <% if @photo.errors.any? %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          <ul class="list-disc list-inside">
            <% @photo.errors.full_messages.each do |message| %>
              <li><%= message %></li>
            <% end %>
          </ul>
        </div>
      <% end %>

      <div class="mb-6">
        <%= f.label :name, "名前", class: "block text-gray-700 text-lg font-bold mb-2" %>
        <%= f.text_field :name, class: "shadow appearance-none border rounded w-full py-3 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline text-lg", placeholder: "山田太郎" %>
      </div>

      <div class="mb-6">
        <%= f.label :image, "写真", class: "block text-gray-700 text-lg font-bold mb-2" %>
        <%= f.file_field :image, accept: "image/*", class: "block w-full text-lg text-gray-700 border border-gray-300 rounded cursor-pointer focus:outline-none", id: "photo_image_input" %>
      </div>

      <div id="image_preview" class="mb-6 hidden">
        <p class="text-gray-700 text-sm font-bold mb-2">プレビュー</p>
        <img id="preview_img" class="max-w-full h-auto rounded shadow-lg" />
      </div>

      <div class="flex items-center justify-center">
        <%= f.submit "アップロード", class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-8 rounded focus:outline-none focus:shadow-outline text-lg cursor-pointer" %>
      </div>
    <% end %>
  </div>
</div>

<script>
  document.getElementById('photo_image_input').addEventListener('change', function(e) {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = function(e) {
        document.getElementById('preview_img').src = e.target.result;
        document.getElementById('image_preview').classList.remove('hidden');
      }
      reader.readAsDataURL(file);
    }
  });
</script>
```

#### 5. ルーティング設定

`config/routes.rb`:
```ruby
Rails.application.routes.draw do
  resources :photos, only: [:new, :create]

  root "photos#new"

  get "up" => "rails/health#show", as: :rails_health_check
end
```

#### 6. 確認手順

```bash
bin/dev
```

- ブラウザで http://localhost:3000 にアクセス
- 名前を入力
- 写真を選択してプレビュー表示を確認
- アップロードボタンを押して保存
- 成功メッセージが表示されることを確認
- Railsコンソールで `Photo.count` を実行してデータが保存されていることを確認

---

## フェーズ2: パスワード認証機能

### 目的
クイズページへのアクセスをパスワードで保護

### 実装手順

#### 1. SessionsControllerの作成

```bash
bin/rails generate controller Sessions new create
```

コントローラー実装（`app/controllers/sessions_controller.rb`）:
```ruby
class SessionsController < ApplicationController
  QUIZ_PASSWORD = "seto-gasshuku-10"

  def new
  end

  def create
    if params[:password] == QUIZ_PASSWORD
      session[:authenticated] = true
      redirect_to quizzes_path, notice: "ログインしました"
    else
      flash.now[:alert] = "パスワードが違います"
      render :new, status: :unprocessable_entity
    end
  end
end
```

#### 2. ApplicationControllerに認証チェックメソッドを追加

`app/controllers/application_controller.rb`:
```ruby
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def require_authentication
    unless session[:authenticated]
      redirect_to new_session_path, alert: "パスワードを入力してください"
    end
  end
end
```

#### 3. ビューの作成

`app/views/sessions/new.html.erb`:
```erb
<div class="min-h-screen bg-gray-900 flex items-center justify-center px-4">
  <div class="max-w-md w-full">
    <div class="bg-white shadow-2xl rounded-lg px-8 pt-8 pb-10">
      <h1 class="text-3xl font-bold text-center mb-8 text-gray-800">クイズを始める</h1>

      <% if alert %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
          <%= alert %>
        </div>
      <% end %>

      <%= form_with url: session_path, method: :post, local: true do |f| %>
        <div class="mb-6">
          <%= f.label :password, "パスワード", class: "block text-gray-700 text-lg font-bold mb-2" %>
          <%= f.password_field :password, class: "shadow appearance-none border rounded w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:shadow-outline text-lg", placeholder: "パスワードを入力", autofocus: true %>
        </div>

        <div class="flex items-center justify-center">
          <%= f.submit "ログイン", class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-8 rounded focus:outline-none focus:shadow-outline text-xl cursor-pointer w-full" %>
        </div>
      <% end %>
    </div>
  </div>
</div>
```

#### 4. ルーティング設定

`config/routes.rb`に追加:
```ruby
resource :session, only: [:new, :create]
```

#### 5. 確認手順

- http://localhost:3000/session/new にアクセス
- 間違ったパスワードを入力してエラーメッセージを確認
- 正しいパスワード `seto-gasshuku-10` を入力
- （次のフェーズでquizzesページを作成するまでは、エラーになるのが正常）

---

## フェーズ3: クイズ問題表示機能

### 目的
ランダムな写真をクイズ問題として表示（名前は非表示）

### 実装手順

#### 1. QuizzesControllerの作成

```bash
bin/rails generate controller Quizzes index show
```

コントローラー実装（`app/controllers/quizzes_controller.rb`）:
```ruby
class QuizzesController < ApplicationController
  before_action :require_authentication

  def index
    photo = Photo.order("RANDOM()").first
    if photo
      redirect_to quiz_path(photo)
    else
      redirect_to new_photo_path, alert: "まだクイズがありません。写真をアップロードしてください。"
    end
  end

  def show
    @photo = Photo.find(params[:id])
  end
end
```

#### 2. ビューの作成

`app/views/quizzes/show.html.erb`:
```erb
<div class="min-h-screen bg-gradient-to-br from-purple-900 to-indigo-900 flex flex-col items-center justify-center px-4 py-8">
  <div class="max-w-5xl w-full">
    <h1 class="text-5xl md:text-6xl font-bold text-center mb-12 text-white drop-shadow-lg">
      この人は誰でしょう？
    </h1>

    <div class="bg-white rounded-3xl shadow-2xl p-4 md:p-8 mb-8">
      <div class="flex items-center justify-center">
        <%= image_tag @photo.image, class: "max-h-[60vh] w-auto rounded-2xl shadow-xl" %>
      </div>
    </div>

    <div class="flex justify-center">
      <%= link_to "答えを見る", quiz_answer_path(@photo), class: "bg-yellow-400 hover:bg-yellow-500 text-gray-900 font-bold py-5 px-12 rounded-full text-3xl shadow-2xl transform hover:scale-105 transition-transform duration-200", data: { turbo: false } %>
    </div>
  </div>
</div>
```

#### 3. ルーティング設定

`config/routes.rb`を更新:
```ruby
resources :quizzes, only: [:index, :show]
```

#### 4. 確認手順

- ログイン後、http://localhost:3000/quizzes にアクセス
- ランダムな写真が大きく表示されることを確認
- 「答えを見る」ボタンが表示されることを確認
- プロジェクター投影を想定した大画面デザインを確認
- 何度かページをリロードして、ランダムに写真が変わることを確認

---

## フェーズ4: 答え表示機能

### 目的
答えページで写真と名前を表示し、次の問題へ進める

### 実装手順

#### 1. AnswersControllerの作成

```bash
bin/rails generate controller Answers show
```

コントローラー実装（`app/controllers/answers_controller.rb`）:
```ruby
class AnswersController < ApplicationController
  before_action :require_authentication

  def show
    @photo = Photo.find(params[:quiz_id])
  end
end
```

#### 2. ビューの作成

`app/views/answers/show.html.erb`:
```erb
<div class="min-h-screen bg-gradient-to-br from-green-900 to-teal-900 flex flex-col items-center justify-center px-4 py-8">
  <div class="max-w-5xl w-full">
    <h1 class="text-5xl md:text-6xl font-bold text-center mb-8 text-white drop-shadow-lg">
      答え
    </h1>

    <div class="bg-white rounded-3xl shadow-2xl p-4 md:p-8 mb-8">
      <div class="flex items-center justify-center mb-6">
        <%= image_tag @photo.image, class: "max-h-[50vh] w-auto rounded-2xl shadow-xl" %>
      </div>

      <h2 class="text-4xl md:text-5xl font-bold text-center text-gray-800 py-6 bg-yellow-100 rounded-xl">
        <%= @photo.name %>
      </h2>
    </div>

    <div class="flex justify-center">
      <%= link_to "次の問題へ", quizzes_path, class: "bg-blue-500 hover:bg-blue-600 text-white font-bold py-5 px-12 rounded-full text-3xl shadow-2xl transform hover:scale-105 transition-transform duration-200" %>
    </div>
  </div>
</div>
```

#### 3. ルーティング設定

`config/routes.rb`を更新（ネストしたリソース）:
```ruby
resources :quizzes, only: [:index, :show] do
  resource :answer, only: [:show]
end
```

最終的なルーティング全体:
```ruby
Rails.application.routes.draw do
  resources :photos, only: [:new, :create]
  resource :session, only: [:new, :create]
  resources :quizzes, only: [:index, :show] do
    resource :answer, only: [:show]
  end

  root "photos#new"

  get "up" => "rails/health#show", as: :rails_health_check
end
```

#### 4. 確認手順

```bash
bin/rails routes
```

以下のルートが表示されることを確認:
```
quiz_answer GET  /quizzes/:quiz_id/answer(.:format)  answers#show
```

ブラウザで全体フローを確認:
1. http://localhost:3000 で写真をアップロード
2. http://localhost:3000/session/new でログイン（`seto-gasshuku-10`）
3. http://localhost:3000/quizzes でランダムな問題が表示される
4. 「答えを見る」ボタンをクリック
5. 答えページで写真と名前が表示される
6. 「次の問題へ」ボタンをクリック
7. 新しいランダムな問題にリダイレクトされる

携帯電話とPCの両方でレスポンシブデザインを確認

---

## 完成後の確認事項

### 機能チェックリスト
- [ ] 写真のアップロードが携帯・PC両方で動作する
- [ ] 画像プレビューが表示される
- [ ] パスワード認証なしではクイズにアクセスできない
- [ ] 正しいパスワードでログインできる
- [ ] ランダムな順序でクイズが表示される
- [ ] 問題ページで名前が表示されていない
- [ ] 答えページで名前が表示される
- [ ] 次の問題へボタンで新しい問題にリダイレクトされる
- [ ] プロジェクター投影に適した大画面デザインになっている
- [ ] Turboでスムーズなページ遷移が行われる

### コマンド確認
```bash
# ルート確認
bin/rails routes

# モデル確認
bin/rails console
> Photo.count
> Photo.first

# テスト実行
bin/rails test
```

### パフォーマンス確認
- 画像サイズが大きすぎないか確認
- 必要に応じてActive Storageのバリアント機能で画像をリサイズ

---

## 今後の拡張案

### 優先度: 低
- 管理画面で写真の削除機能
- 既に表示した問題を記録して、同じ問題を連続で出さない
- 画像の自動リサイズ
- アップロード時の画像形式・サイズバリデーション
- クイズの統計情報（全何問など）
- セッションタイムアウト機能
- ログアウト機能

### 優先度: 中
- 複数画像の一括アップロード
- 画像の編集機能（トリミング等）

### 優先度: 高（本番運用前に検討）
- 本番環境でのストレージ設定（S3等）
- 画像の圧縮・最適化
- セキュリティ強化（CSRF対策、XSS対策の確認）
