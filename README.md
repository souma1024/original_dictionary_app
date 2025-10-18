# original_dict_app
オリジナル辞書アプリ

[企画書](./docs/e-team_kikaku_up.pdf)
[基本設計書](./docs/e-team_kihon_up.pdf)

## 使用技術
#### フロントエンド　（モバイルアプリ）
- Flutter 3.35.5 （FVMによりバージョン固定）
- Dart 3.9.2

#### 対応プラットフォーム
- Android 

#### 開発ツール
- Android Studio / VS Code
- FVM（Flutter SDK管理）
- dart format / flutter analyze（静的解析・整形）

#### ライブラリ・パッケージ
- flutter (SDK)
- cupertino_icons
※今後追加予定

#### コーディング規約
- Lint: flutter_lints（analysis_options.yaml）
- Format: dart format


## Android Studioのインストール手順
[参考サイト](https://zenn.dev/heyhey1028/books/flutter-basics/viewer/getting_started_windows#3.android-studio-%E3%81%AE%E3%82%BB%E3%83%83%E3%83%88%E3%82%A2%E3%83%83%E3%83%97)

## Git・Githubについて
[参考サイト：インストール方法](https://qiita.com/takeru-hirai/items/4fbe6593d42f9a844b1c) <br>

<dl>
  <dt>git とは</dt>
  <dd>ファイルの変更履歴を保存して、いつでも過去の状態に戻したりすることができるツール。</dd>
　<dt>github とは</dt>
  <dd>ソースコードをアップロードし簡単に管理、共有できるWebサービス</dd>
</dl>

### git・githubにおける重要な概念
<dl>
  <dt>リモートリポジトリとは</dt>
  <dd>ネットワーク上のサーバー（Github）に保存され、複数の開発者で共有するための、データや変更履歴を管理する場所（リポジトリ）（クラウド上に保存）</dd>
　<dt>ローカルリポジトリとは</dt>
  <dd>ホストPCに作成されるリポジトリ（自身のPCに保存）</dd>
　<dt>ブランチとは</dt>
  <dd>
        プロジェクトのコードの履歴を分岐させ、他の作業に影響を与えずに新しい機能開発やバグ修正を行うための仕組み<br>
        つまり、デフォルトのmainブランチを分岐させて、developブランチを作った場合、developブランチを変更してもmainブランチには何も影響しない<br>
        したがって、機能ごとにブランチを分けたりすることで開発しやすくなる。（後で、mainブランチやdevelopブランチに統合すればよい）
  </dd>
</dl>

<br>

### よく使う基本コマンド
```
git clone https://example.com/main.git
# リモートリポジトリをローカルに複製（初回のみ）

git pull origin (branch)
# リモートの(branch)の変更を取得し、現在のブランチに取り込む

git push origin (branch)
# ローカルの(branch)の変更をリモートの同名ブランチに反映する

git add (file or directory)
# (file or directory)の変更をコミット対象としてステージング（追跡対象に入れる）する

git commit -m "メッセージ"
# ステージングされた変更を1つの履歴としてローカルに保存する

git switch -c (new branch name)
#　ローカルリポジトリに新しいブランチを作成し、そのブランチに移動する

git checkout (branch name)
# (branch name)に移動する

git status
# 現在のGitリポジトリの状態を確認するためのコマンド

git branch
# ローカルブランチの一覧を表示する。
```

## セットアップ手順

1. scoopというwindowsで動くパッケージマネージャをインストール。
```
#powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

2. scoop経由で、fvm(flutter version management)をインストール
```
scoop bucket add extras
scoop install fvm
```

3. このリポジトリをホストPCにコピー。
```
git clone https://github.com/souma1024/original_dictionary_app.git　 #
```
4. ディレクトリを移動
```
cd original_dictionary_app
```

5. 指定したバージョン(今回は、3.35.5)のFlutter SDKをローカルPCにインストールのみをするコマンド
```
original_dictionary_app> fvm install
```
6. 指定したバージョンを使用するコマンド
```
original_dictionary_app> fvm use
```
7. 指定されたバージョンにおいて、pubspec.yaml の依存パッケージを取得する
```
original_dictionary_app> fvm flutter pub get
```
8. 指定された Flutter バージョンでアプリを実行
```
original_dictionary_app> fvm flutter run
```

## 開発の進め方

### 0.ローカルリポジトリをリモートリポジトリで上書き mainブランチで以下のコマンドを実行
```
  git pull origin main
```

### 1. 開発したい機能をIssueの中から選ぶ

### 2. mainブランチから以下のコマンドを行いブランチを分ける。
```
  git switch -c (branch名) #(branch名)はIssueに書いてあるブランチ名を使ってください
```
### 3.コードを記述していきIssueの機能を完成させる。細かい機能を完成させたらコミットすると良い！
```
  git add .                          
  git commit -m "(コメントを書く)"
```
### 4.完成したら、以下のコマンドを行いリモートリポジトリにローカルリポジトリをpush
```
  git push -u origin (branch名) #(branch名)は現在のブランチ名
```
### 5. 4のコマンドをするとgithub上にPR(Pull Request)が作成要求がされる。コメントなどを追加して、PRを作成

### 6. レビューをし、問題がなければマージ、そうでなければコードを修正する。

### 7.無事にマージできたら完了

### 8. リモートリポジトリgithubに作成されたブランチを削除 (<span style="color:red;">mainブランチは絶対に削除しない！！</span>)

### 9. 1に戻り新しい機能を開発


## ディレクトリ構成案
```
lib/
├── main.dart        ← ★ ここがアプリの入口
│
├── screens/         ←　画面ごとに機能を分けるためのディレクトリ
│   ├── cards_creation/   ← カード作成画面
│   │   └── cards.dart
│   └── home/　           ← ホーム画面
│       ├── home_main.dart
│       ├── home_detail.dart
│       └── home_edit.dart
│
├── controllers/      ← 状態管理
│
├── models/           ← データクラス（cardsやtagsなど）
│
├── data/
│   └──── app_database.dart  ← DB初期化
│       
│
└── utils/            ← バリデータ、共通メソッド、定数など
```

## 参考サイト
[Dart・Flutterの基本的な文法と仕組み](https://zenn.dev/heyhey1028/books/flutter-basics/viewer/dart_intro) <br>
[Flutter公式サイト](https://flutter.ctrnost.com/) <br>
[Flutter公式アイコン](https://api.flutter.dev/flutter/material/Icons-class.html)








