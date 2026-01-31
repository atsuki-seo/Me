---
title: "ダミー記事06：SwiftUI実践"
date: 2026-01-20T12:00:00+09:00
description: "これはページング検証用のダミー記事06です。SwiftUIの実践的な使い方を解説します。"
tags: ["Swift", "SwiftUI", "iOS", "開発"]
---

## 概要

これはページング検証用のダミー記事です。

## SwiftUIの基本

SwiftUIは宣言的UIフレームワークで、直感的にUIを構築できます。

### サンプルコード

```swift
struct ContentView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("カウント: \(count)")
            Button("増やす") {
                count += 1
            }
        }
    }
}
```
