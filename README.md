# original_dict_app
オリジナル辞書アプリ

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

## Git Githubについて

## セットアップ手順
``` powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop bucket add extras
scoop install fvm

git clone https://github.com/souma1024/original_dictionary_app.git
original_dictionary_app> fvm install
original_dictionary_app> fvm use
original_dictionary_app> fvm flutter pub get
original_dictionary_app> fvm flutter run
```

### fvm (Flutter Version Management)のインストール手順





