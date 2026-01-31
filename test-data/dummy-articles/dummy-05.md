---
title: "ダミー記事05：Docker入門"
date: 2026-01-19T12:00:00+09:00
description: "これはページング検証用のダミー記事05です。Dockerの基本的な使い方を解説します。"
tags: ["Docker", "入門", "開発"]
---

## 概要

これはページング検証用のダミー記事です。

## Dockerとは

Dockerはコンテナ型の仮想化技術で、アプリケーションの実行環境を簡単に構築できます。

### 基本コマンド

```bash
# イメージの取得
docker pull nginx

# コンテナの起動
docker run -d -p 80:80 nginx

# コンテナの一覧
docker ps
```
