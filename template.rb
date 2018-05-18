@app_name = app_name
repo_url = "https://raw.github.com/gacktomo/Rails-API-template/master"

# Gemfile
gem 'rack-cors'
gem 'puma'
gem_group :development, :test do
  gem 'pry-rails'    # rails cの対話式コンソールがirbの代わりにリッチなpryになる
  gem 'pry-doc'      # pry中に show-source [method名] でソース内を読める
  gem 'pry-byebug'   # binding.pryをソースに記載すると、ブレイクポイントとなりデバッグが可能になる
  gem 'pry-stack_explorer' # pry中にスタックを上がったり下がったり行き来できる

  gem 'hirb'         # モデルの出力結果を表形式で表示する
  gem 'hirb-unicode' # hirbの日本語などマルチバイト文字の出力時の出力結果がすれる問題に対応
  gem 'rails-flog', require: 'flog' # HashとSQLのログを見やすく整形
  gem 'better_errors'     # 開発中のエラー画面をリッチにする
  gem 'binding_of_caller' # 開発中のエラー画面にさらに変数の値を表示する
  gem 'awesome_print'     # Rubyオブジェクトに色をつけて表示して見やすくなる
end

get "#{repo_url}/config/locales/ja.yml", "config/locales/ja.yml"

gsub_file 'config/database.yml',
  /^  password:$/, "  password: <%= ENV.fetch('MYSQL_PASSWORD') %>"


insert_into_file "config/application.rb",%(
  config.i18n.default_locale = :ja
  config.time_zone = 'Tokyo'
),after: "class Application < Rails::Application\n"

after_bundle do
  gsub_file 'config/puma.rb',
    /^port        ENV.fetch\("PORT"\) { 3000 }$/, 
"#port        ENV.fetch(\"PORT\") { 3000 }

daemonize true
pidfile 'tmp/pids/puma.pid'
 
if 'development' == ENV.fetch('RAILS_ENV') { 'development' }
  ssl_bind '0.0.0.0', '3010', {
    key: '/etc/letsencrypt/live/docoiku.com/privkey.pem',
    cert: '/etc/letsencrypt/live/docoiku.com/fullchain.pem',
    verify_mode: 'none'
  }
end
"

  insert_into_file "config/application.rb",%(
    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end
  ),after: "class Application < Rails::Application\n"

  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }

end

