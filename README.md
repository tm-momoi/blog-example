## Railsで2時間でブログを作成しよう!!

### docker起動
##### まず、Railsを起動するサーバーを立ててみましょう。  
Windows Powershellを開き、下記のコマンドを実行してください。
```
docker run --privileged -it -p 3000:3000 -v C:\Users\tcmobile\Desktop\1day_intern:/1day_intern --name rails rails:latest
```
Kitematicを起動し、Containersの"rails"を選択、中央上部にあるEXECボタンを選択してください。  
Windows Powershellが表示されたら下記のコマンドを入力してください。
```
cd 1day_intern
```

### Rails基盤作成
##### Railsの枠組みを作成してみましょう。    
Windows Powershellで下記のコマンドを入力してください。
```
rails new blog-example --skip-bundle
cd blog-example
```

/Gemfileの20行目に下記を記述してください。
```
gem 'bcrypt-ruby', '3.1.1.rc1', :require => 'bcrypt'
```

Windows Powershellで下記のコマンドを実行します。      
このコマンドだけでほとんどのページが作成されてしまう恐ろしいコマンドです。
```
bundle install --path /usr/local/src/bundles/blog-example
rails g scaffold User name:string email:string password_digest:string created_at:date updated_at:date
rails g scaffold Article title:string writer:string contents:text memberOnly:boolean created_at:date updated_at:date
```

### DB作成
##### 次にデータベースを作成してみましょう。  
Windows Powershellで下記のコマンドを実行してください。
```
rake db:migrate
```

### 初期データ投入
##### 初期データをデータベースに投入してみましょう。  
/db/seed.rbに下記を記述してください。  
ここでは元データを作成しています。
```
10.times do |i|
  Article.create(title: "タイトル#{i}", writer: "ジロー", memberOnly: i % 2, contents: "この文章はダミーです。文字の大きさ、量、字間、行間等を確認するために入れています。")
end
```
/Windows Powershellで下記のコマンドを実行してください。  
このコマンドで実際にDBに値を入れています。
```
rake db:seed
```

### パスワード暗号化設定
##### パスワードを暗号化して保存するようにしてみましょう。
/app/model/user.rbの```class User < ApplicationRecord```と```end```の間に下記を追加してください。
```
has_secure_password validations: true
```

/app/views/users/\_form.html.erbで以下を変更してください。
```
<div class="field">
  <%= f.label :password_digest %>
  <%= f.text_field :password_digest, id: :user_password_digest %>
</div>

↓

<div class="field">
  <%= f.label :password %>
  <%= f.text_field :password, id: :user_password %>
</div>
```

/app/controllers/users_controller.rbで以下を変更してください。
```
def user_params
  params.require(:user).permit(:name, :email, :password_digest, :created_at, :updated_at)
end

↓

def user_params
  params.require(:user).permit(:name, :email, :password, :created_at, :updated_at)
end
```

ここで一度ページを見てみましょう。     
Windows Powershellで下記のコマンドを実行し、*http://localhost:3000* にアクセスしてください。
```
rails s
```



### TOPページ作成
##### 現在TOPページ設定されていないのでTOPページを設定してみましょう。  
/app/views配下にindexフォルダ作成、その中にindex.html.erbを作成し、下記を記述してください。  
これがTOPページに表示されるHTMLになります。
```
<%= link_to 'Article', articles_path %>
<%= link_to 'User', users_path %>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Writer</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @articles.each do |article| %>
      <tr>
        <td><%= article.title %></td>
        <td><%= article.writer %></td>
        <td><%= link_to 'Show', article %></td>
      </tr>
    <% end %>
  </tbody>
</table>
```

/config/routes.rbの```Rails.application.routes.draw do ~ end```の間に下記を記述してください。  
ここではTOPページのルーティングの設定をしています。
```
root 'index#index'
```

/app/controller配下にindex_controller.rb作成し、下記を記述してください。

```
class IndexController < ApplicationController

  def index
    @articles = Article.all
  end

end
```

ページを確認してみましょう。  
Windows Powershellで下記のコマンドを実行し、http://localhost:3000 にアクセスしてください。
```
rails s
```
TOPページに今作成したページが表示されているはずです。


### ヘッダー、フッダー作成
##### ページにヘッダーとフッターをつけてみましょう。
/app/views/layouts/application.html.erb 11行目 ```<%= yield %>``` の前後に下記を記述してください。  
このapplication.html.erbはすべてのViewから呼び出されます。  
```<%= yield %>``` の位置に他のViewの内容が挿入されます
```
<div class="header" style="border-bottom:solid 1px #ccc; margin-bottom:10px; padding-bottom:10px;">
  <h1>Blog-example</h1>
</div>
<%= yield %>
<div class="footer" style="border-top:solid 1px #ccc; margin-top:10px; padding-top:10px;">
  <%= link_to 'TOP', root_path %>
</div>
```
ページを確認してみましょう。  
Windows Powershellで下記のコマンドを実行し、http://localhost:3000 にアクセスしてください。
```
rails s
```
すべてのページにヘッダーとフッターが表示されているはずです。

### ログイン機能実装
##### ログイン機能を実装してみましょう。

Windows Powershellで下記のコマンドを実行してください。  
ログインを処理するMVCを作成します。
```
rails g controller Sessions new
```
/config/routes.rbの```Rails.application.routes.draw do```と```end```の間に下記を追加してください。  
ログインのルーティングの設定をしています。
```
get 'login', to: 'sessions#new'
post 'login', to: 'sessions#create'
delete 'logout', to: 'sessions#destroy'
```

/app/controllers/sessions_controller.rbを下記に変更してください。  
ログインのコントローラーの設定をしています。
```
class SessionsController < ApplicationController
  before_action :set_user, only: [:create]

  skip_before_action :require_sign_in!, raise: false, only: [:new, :create]

  def new
  end

  def create
    if @user.authenticate(session_params[:password])
      sign_in(@user)
      redirect_to root_path
    else
      flash.now[:danger] = t('.flash.invalid_password')
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to login_path
  end

  def require_sign_in!
    require_sign_in!
  end

  private

    def set_user
      @user = User.find_by!(email: session_params[:email])
    rescue
      flash.now[:danger] = t('.flash.invalid_mail')
      render action: 'new'
    end

    # 許可するパラメータ
    def session_params
      params.require(:session).permit(:email, :password)
    end

end
```

/app/views/sessions/new.html.erbの最後に下記を追加してください。  
これがログインの画面になります。
```
<%= form_for :session, url: login_path do |f| %>
  <div>
    <label>メールアドレス</label>
    <%= f.text_field :email %>
  </div>
  <div>
    <label>パスワード</label>
    <%= f.password_field :password %>
  </div>

  <%= f.submit 'ログイン' %>
<% end %>
```

/app/controllers/application_controller.rbの```protect_from_forgery with: :exception```の後に下記を追記してください。  
ログインしているか判定する処理になります。
```
before_action :current_user
helper_method :signed_in?

def current_user
  @current_user ||= User.find_by(id: session[:user_id])
end

def sign_in(user)
  session[:user_id] = user.id
  @current_user = user
end

def sign_out
  @current_user = nil
  reset_session
end

def signed_in?
  @current_user.present?
end

private
  def require_sign_in!
    redirect_to login_path unless signed_in?
  end
```

/app/views/layout/application.html.erbの```<h1>Blog-example</h1>```の後に下記を追加してください。  
ログインページへのリンクを作成しています。
```
<% if @current_user %>
  <p><%= @current_user.name %> | <%= link_to 'ログアウト', logout_path, method: :delete %></p>
<% else %>
  <%= link_to 'ログイン', login_path %>
<% end %>
```

ログイン機能を確認してみましょう。  
Windows Powershellで下記のコマンドを実行し、http://localhost:3000 にアクセスしてください。
```
rails s
```
Userを作成し、ログインをしてみましょう。  
成功した場合はヘッダーにログインユーザーの名前が表示されるはずです。




### 会員限定機能
##### 会員限定機能を実装してみましょう。
##### 会員のみが記事の作成、会員限定記事の表示をできるようにします。
/app/controllers/articles_controller.rbの```before_action :set_article, only: [:show, :edit, :update, :destroy]```の後に下記を追加してください。  
Articleをログインしていないと作成できないようにしています。
```
before_action :require_sign_in!, only: [:new, :create, :edit, :update, :destroy]
```

/app/model/article.rbの```class Blog < ApplicationRecord```と```end```の間に下記を追加してください。  
ログイン状況に応じた記事を取り出す処理になります。
```
def self.getArticles(isMember = false)
  if (isMember)
    Article.all
  else
    Article.where(memberOnly: false)
  end
end
```

/app/controllers/articles_controller.rbの```def index```と```def create```を下記のように変更してください。  
ログイン状況に応じて記事を取得するようにしています。
```
def index
  @articles = Article.getArticles(signed_in?)
end

def create
  @article = Article.new(article_params)
  @article.writer = @current_user.name
  respond_to do |format|
    if @article.save
      format.html { redirect_to @article, notice: 'News was successfully created.' }
      format.json { render :show, status: :created, location: @article }
    else
      format.html { render :new }
      format.json { render json: @article.errors, status: :unprocessable_entity }
    end
  end
end
```

/app/controllers/index_controller.rbの```def index```を下記のように変更してください。
ログイン状況に応じて記事を取得するようにしています。
```
def index
  @articles = Article.getArticles(signed_in?)
end
```

/app/views/articles/_form.html.erbから以下を削除してください。  
ライター、作成日時、更新日時のフォームを削除します。
```
<div class="field">
  <%= form.label :writer %>
  <%= form.text_field :writer, id: :article_writer %>
</div>

<div class="field">
  <%= form.label :created_at %>
  <%= form.date_select :created_at, id: :article_created_at %>
</div>

<div class="field">
  <%= form.label :updated_at %>
  <%= form.date_select :updated_at, id: :article_updated_at %>
</div>
```

会員限定機能を確認してみましょう。  
Windows Powershellで下記のコマンドを実行し、http://localhost:3000 にアクセスしてください。
```
rails s
```
ログインなしで記事を作成しようとするとログインページにとばされるはずです。  
また、会員限定の記事も表示されていないはずです。

### バリデーション
##### 今フォームが空の状態でも登録できてしまうのでバリデーションを設定しましょう。

/app/models/article.rbの```class Article < ApplicationRecord```の後に下記を追加してください。
タイトルとコンテンツが空の状態で登録ができないようにしています。
```
validates :title, presence:true
validates :contents, presence: true
```

/app/models/user.rbの```has_secure_password validations: true```の後に下記を追加してください。
名前とメールアドレスが空の状態で登録ができないようにしています。
```
validates :name, presence:true
validates :email, presence: true
```

実際にuserを名前、メールアドレスが空の状態で登録してみてください。

余裕がある人は下記のバリデーションも追加してみましょう。  

##### User

|データ名|バリデーション|
|:--|:--|
|名前|50文字以内|
|メールアドレス|100文字以内 + メールアドレス形式のみ(-@-)|

##### Article

|データ名|バリデーション|
|:--|:--|
|タイトル|100文字以内|
|コンテンツ|1000文字以内|

### デザイン
##### ページが味気ないのでデザインをしてみましょう。
##### 今回はBootstrapを使用してデザインしたいと思います。

/app/views/layouts/application.html.erbの```<title>BlogExample</title>```の後に下記を追加してください。  
Bootstrapを使用するために必要になります。

```
<meta name="viewport" content="width=device-width, initial-scale=1">
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
```

TOPページのテーブルの表示を綺麗にしたいと思います。
/app/views/index/index.html.erbの```<table>```に"table"というクラス名を追加します。
```
<table class="table">
```

TOPページにアクセスしてみてください。
TOPページの記事一覧が整形されていると思います。

以下のページを参考に自分で思うがままのデザインをしてみましょう。  
http://bootstrap3.cyberlab.info/
