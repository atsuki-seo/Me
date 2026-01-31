#!/bin/bash
#
# manage-dummy.sh
# ページング検証用ダミー記事の管理スクリプト
#

set -euo pipefail

# スクリプトのディレクトリからプロジェクトルートを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BLOG_DIR="${PROJECT_ROOT}/content/blog"
DUMMY_STORAGE="${PROJECT_ROOT}/test-data/dummy-articles"
DUMMY_PATTERN="dummy-*.md"

# オプション
DRY_RUN=false
VERBOSE=false

# ヘルプ表示
show_help() {
    cat << EOF
使用方法: $(basename "$0") <コマンド> [オプション]

ページング検証用ダミー記事の管理を行います。

コマンド:
  enable              ダミー記事をcontent/blog/にコピー
  disable             content/blog/からダミー記事を削除
  status              ダミー記事の状態を表示
  create [件数]       新しいダミー記事を生成（デフォルト: 1件）

オプション:
  -n, --dry-run       実行せずにプレビューのみ
  -v, --verbose       詳細なログを出力
  -h, --help          このヘルプを表示

例:
  $(basename "$0") enable           # ダミー記事を有効化
  $(basename "$0") disable          # ダミー記事を無効化
  $(basename "$0") status           # 現在の状態を確認
  $(basename "$0") create 5         # 5件のダミー記事を追加生成
EOF
}

# ログ出力
log() {
    echo "$1"
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo "$1" >&2
    fi
}

# アーカイブを再生成
regenerate_archives() {
    if [[ "$DRY_RUN" == true ]]; then
        log ""
        log "[DRY-RUN] アーカイブを再生成します"
        return
    fi

    log ""
    log "アーカイブを再生成しています..."
    local archive_script="${SCRIPT_DIR}/generate-archives.sh"
    if [[ -x "$archive_script" ]]; then
        "$archive_script"
    else
        echo "警告: generate-archives.sh が見つかりません" >&2
    fi
}

# 環境チェック
check_environment() {
    # Hugoプロジェクトルートかチェック
    if [[ ! -f "${PROJECT_ROOT}/hugo.toml" ]]; then
        echo "エラー: Hugoプロジェクトルートで実行してください" >&2
        echo "       hugo.toml が見つかりません: ${PROJECT_ROOT}" >&2
        exit 1
    fi

    # ダミー記事保管ディレクトリの確認
    if [[ ! -d "$DUMMY_STORAGE" ]]; then
        echo "エラー: ダミー記事保管ディレクトリが存在しません: ${DUMMY_STORAGE}" >&2
        exit 1
    fi

    log_verbose "プロジェクトルート: ${PROJECT_ROOT}"
    log_verbose "ブログディレクトリ: ${BLOG_DIR}"
    log_verbose "ダミー記事保管: ${DUMMY_STORAGE}"
}

# 保管ダミー記事の件数を取得
get_storage_count() {
    shopt -s nullglob
    local files=("${DUMMY_STORAGE}"/${DUMMY_PATTERN})
    echo "${#files[@]}"
}

# 有効化されたダミー記事の件数を取得
get_enabled_count() {
    shopt -s nullglob
    local files=("${BLOG_DIR}"/${DUMMY_PATTERN})
    echo "${#files[@]}"
}

# ダミー記事を有効化
cmd_enable() {
    check_environment

    local storage_count
    storage_count=$(get_storage_count)

    if [[ "$storage_count" -eq 0 ]]; then
        log "保管されているダミー記事がありません"
        exit 0
    fi

    local enabled_count
    enabled_count=$(get_enabled_count)

    if [[ "$enabled_count" -gt 0 ]]; then
        log "既にダミー記事が有効化されています (${enabled_count}件)"
        log "先に disable を実行してください"
        exit 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] 以下のダミー記事を有効化します:"
    else
        log "ダミー記事を有効化しています..."
    fi

    shopt -s nullglob
    local count=0
    for file in "${DUMMY_STORAGE}"/${DUMMY_PATTERN}; do
        local filename
        filename=$(basename "$file")
        if [[ "$DRY_RUN" == true ]]; then
            log "  [DRY-RUN] ${filename}"
        else
            cp "$file" "${BLOG_DIR}/${filename}"
            log_verbose "  コピー: ${filename}"
        fi
        ((++count))
    done

    if [[ "$DRY_RUN" == true ]]; then
        log "合計: ${count} 件"
    else
        log "完了: ${count} 件のダミー記事を有効化しました"
    fi

    # アーカイブを再生成
    regenerate_archives
}

# ダミー記事を無効化
cmd_disable() {
    check_environment

    local enabled_count
    enabled_count=$(get_enabled_count)

    if [[ "$enabled_count" -eq 0 ]]; then
        log "有効化されているダミー記事はありません"
        exit 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] 以下のダミー記事を削除します:"
    else
        log "ダミー記事を無効化しています..."
    fi

    shopt -s nullglob
    local count=0
    for file in "${BLOG_DIR}"/${DUMMY_PATTERN}; do
        local filename
        filename=$(basename "$file")
        if [[ "$DRY_RUN" == true ]]; then
            log "  [DRY-RUN] ${filename}"
        else
            rm "$file"
            log_verbose "  削除: ${filename}"
        fi
        ((++count))
    done

    if [[ "$DRY_RUN" == true ]]; then
        log "合計: ${count} 件"
    else
        log "完了: ${count} 件のダミー記事を無効化しました"
    fi

    # アーカイブを再生成
    regenerate_archives
}

# 状態を表示
cmd_status() {
    check_environment

    local storage_count
    storage_count=$(get_storage_count)

    local enabled_count
    enabled_count=$(get_enabled_count)

    log "ダミー記事の状態:"
    log "  保管: ${storage_count} 件 (${DUMMY_STORAGE})"
    log "  有効: ${enabled_count} 件 (${BLOG_DIR})"

    if [[ "$enabled_count" -gt 0 ]]; then
        log ""
        log "ステータス: 有効化されています"
    else
        log ""
        log "ステータス: 無効化されています"
    fi
}

# 新しいダミー記事を生成
cmd_create() {
    local count="${1:-1}"

    check_environment

    # 数値チェック
    if ! [[ "$count" =~ ^[0-9]+$ ]] || [[ "$count" -lt 1 ]]; then
        echo "エラー: 生成件数は1以上の整数で指定してください" >&2
        exit 1
    fi

    # 既存の最大番号を取得
    local max_num=0
    shopt -s nullglob
    for file in "${DUMMY_STORAGE}"/dummy-*.md; do
        local filename
        filename=$(basename "$file" .md)
        local num
        num=$(echo "$filename" | sed 's/dummy-0*//')
        if [[ "$num" =~ ^[0-9]+$ ]] && [[ "$num" -gt "$max_num" ]]; then
            max_num="$num"
        fi
    done

    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] 以下のダミー記事を生成します:"
    else
        log "ダミー記事を生成しています..."
    fi

    local created=0
    for ((i = 1; i <= count; i++)); do
        local new_num=$((max_num + i))
        local padded_num
        padded_num=$(printf "%02d" "$new_num")
        local new_file="${DUMMY_STORAGE}/dummy-${padded_num}.md"
        local title="ダミー記事${padded_num}：サンプルコンテンツ"
        local date
        date=$(date -d "+$((i - 1)) days" +"%Y-%m-%dT12:00:00+09:00")

        if [[ "$DRY_RUN" == true ]]; then
            log "  [DRY-RUN] dummy-${padded_num}.md"
        else
            cat > "$new_file" << EOF
---
title: "${title}"
date: ${date}
description: "これはページング検証用のダミー記事${padded_num}です。"
tags: ["ダミー", "検証"]
---

## 概要

これはページング検証用のダミー記事です。

## サンプルコンテンツ

この記事はページング機能の検証のために自動生成されました。

- 項目1
- 項目2
- 項目3
EOF
            log_verbose "  作成: dummy-${padded_num}.md"
        fi
        ((++created))
    done

    if [[ "$DRY_RUN" == true ]]; then
        log "合計: ${created} 件"
    else
        log "完了: ${created} 件のダミー記事を生成しました"
    fi
}

# メイン処理
main() {
    local command=""
    local args=()

    # 引数解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                echo "エラー: 不明なオプション: $1" >&2
                show_help >&2
                exit 1
                ;;
            *)
                if [[ -z "$command" ]]; then
                    command="$1"
                else
                    args+=("$1")
                fi
                shift
                ;;
        esac
    done

    # コマンドが指定されていない場合
    if [[ -z "$command" ]]; then
        show_help
        exit 1
    fi

    # コマンド実行
    case "$command" in
        enable)
            cmd_enable
            ;;
        disable)
            cmd_disable
            ;;
        status)
            cmd_status
            ;;
        create)
            cmd_create "${args[0]:-1}"
            ;;
        *)
            echo "エラー: 不明なコマンド: $command" >&2
            show_help >&2
            exit 1
            ;;
    esac
}

main "$@"
