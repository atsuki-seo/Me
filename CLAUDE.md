# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ルール

- 日本語でやり取りすること
- コミットは必ず日本語でなるべく粒度を細かくすること
- コミットはユーザの指示があるまでしないし確認もしないこと
- 毎作業ごとにCLAUDE.md 更新が必要かどうかを確認し必要に応じて更新すること

## プロジェクト情報

[README.md](README.md) を参照

## 開発環境

### Hugo開発サーバー

```bash
cd ~/ドキュメント/Me
hugo server --noHTTPCache
```

- URL: http://localhost:1313/

### ディレクトリ構造

- `layouts/` - Hugoテンプレート
  - `layouts/index.html` - トップページ
  - `layouts/blog/` - ブログ用テンプレート
  - `layouts/partials/` - 共通パーツ
- `content/blog/` - ブログ記事（Markdown）
- `static/` - 静的ファイル（CSS, JS, 画像）
- `test-data/dummy-articles/` - ページング検証用ダミー記事

### ダミー記事管理

ページング機能の検証用にダミー記事を管理するスクリプト。

```bash
# ダミー記事を有効化（content/blog/にコピー）
./scripts/manage-dummy.sh enable

# ダミー記事を無効化（content/blog/から削除）
./scripts/manage-dummy.sh disable

# 状態を確認
./scripts/manage-dummy.sh status

# 新しいダミー記事を生成（例: 5件）
./scripts/manage-dummy.sh create 5
```

- デプロイ時は GitHub Actions で自動的に無効化される
- `content/blog/dummy-*.md` は `.gitignore` で除外済み
