---
title: "ダミー記事07：CI/CD構築"
date: 2026-01-21T12:00:00+09:00
description: "これはページング検証用のダミー記事07です。CI/CDパイプラインの構築方法を解説します。"
tags: ["CI/CD", "開発"]
---

## 概要

これはページング検証用のダミー記事です。

## CI/CDとは

CI（継続的インテグレーション）とCD（継続的デリバリー）を組み合わせた開発手法です。

### GitHub Actionsの例

```yaml
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: npm test
```
