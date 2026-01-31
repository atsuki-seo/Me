---
title: "ダミー記事10：API設計"
date: 2026-01-24T12:00:00+09:00
description: "これはページング検証用のダミー記事10です。REST APIの設計原則を解説します。"
tags: ["API", "開発"]
---

## 概要

これはページング検証用のダミー記事です。

## REST API設計

RESTfulなAPIを設計する際の基本原則を紹介します。

### エンドポイント設計

```
GET    /users          # ユーザー一覧
GET    /users/:id      # ユーザー詳細
POST   /users          # ユーザー作成
PUT    /users/:id      # ユーザー更新
DELETE /users/:id      # ユーザー削除
```

### ステータスコード

- `200 OK`：成功
- `201 Created`：作成成功
- `400 Bad Request`：リクエストエラー
- `404 Not Found`：リソースなし
