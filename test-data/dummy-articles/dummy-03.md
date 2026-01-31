---
title: "ダミー記事03：Hugoテーマ作成"
date: 2026-01-17T12:00:00+09:00
description: "これはページング検証用のダミー記事03です。Hugoテーマの作成方法を解説します。"
tags: ["Hugo", "Web", "開発"]
---

## 概要

これはページング検証用のダミー記事です。

## Hugoテーマの構造

Hugoテーマは以下のディレクトリ構造で作成します。

```
themes/my-theme/
├── layouts/
│   ├── _default/
│   └── partials/
├── static/
│   ├── css/
│   └── js/
└── theme.toml
```

### テンプレートの基本

- `baseof.html`：ベーステンプレート
- `single.html`：個別ページ
- `list.html`：一覧ページ
