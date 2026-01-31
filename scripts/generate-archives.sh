#!/bin/bash
#
# generate-archives.sh
# ブログ記事から月別アーカイブページを自動生成するスクリプト
#

set -euo pipefail

# スクリプトのディレクトリからプロジェクトルートを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BLOG_DIR="${PROJECT_ROOT}/content/blog"

# オプション
DRY_RUN=false
VERBOSE=false

# ヘルプ表示
show_help() {
    cat << EOF
使用方法: $(basename "$0") [オプション]

ブログ記事から月別アーカイブページを自動生成します。

オプション:
  -n, --dry-run    ファイルを作成せず、生成予定のみ表示
  -v, --verbose    詳細なログを出力
  -h, --help       このヘルプを表示

例:
  $(basename "$0")              # アーカイブを生成
  $(basename "$0") --dry-run    # 生成予定を確認
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

# オプション解析
parse_options() {
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
            *)
                echo "エラー: 不明なオプション: $1" >&2
                show_help >&2
                exit 1
                ;;
        esac
    done
}

# 環境チェック
check_environment() {
    # Hugoプロジェクトルートかチェック
    if [[ ! -f "${PROJECT_ROOT}/hugo.toml" ]]; then
        echo "エラー: Hugoプロジェクトルートで実行してください" >&2
        echo "       hugo.toml が見つかりません: ${PROJECT_ROOT}" >&2
        exit 1
    fi

    # content/blogディレクトリの存在確認
    if [[ ! -d "$BLOG_DIR" ]]; then
        echo "エラー: content/blog ディレクトリが存在しません" >&2
        exit 1
    fi

    log_verbose "プロジェクトルート: ${PROJECT_ROOT}"
    log_verbose "ブログディレクトリ: ${BLOG_DIR}"
}

# 年月を抽出
extract_year_months() {
    local year_months=""

    # ブログ記事を走査（_index.md と サブディレクトリを除外）
    shopt -s nullglob
    local files=("${BLOG_DIR}"/*.md)

    if [[ ${#files[@]} -eq 0 ]]; then
        log "警告: ブログ記事が見つかりません"
        return
    fi

    for file in "${files[@]}"; do
        local filename
        filename=$(basename "$file")

        # _index.md はスキップ
        if [[ "$filename" == "_index.md" ]]; then
            continue
        fi

        # Front Matterからdateを抽出
        local date_line
        date_line=$(grep -m1 "^date:" "$file" 2>/dev/null || true)

        if [[ -z "$date_line" ]]; then
            echo "警告: ${filename} にdateフィールドがありません" >&2
            continue
        fi

        # date: 2026-01-15T12:00:00+09:00 から年月を抽出
        local year_month
        year_month=$(echo "$date_line" | sed -n 's/^date: *\([0-9]\{4\}\)-\([0-9]\{2\}\).*/\1 \2/p')

        if [[ -z "$year_month" ]]; then
            echo "警告: ${filename} の日付形式が不正です: ${date_line}" >&2
            continue
        fi

        log_verbose "  ${filename}: ${year_month}"
        year_months="${year_months}${year_month}"$'\n'
    done

    # 重複排除してソート
    echo "$year_months" | sort -u | grep -v "^$" || true
}

# アーカイブファイルを生成
generate_archive() {
    local year="$1"
    local month_padded="$2"

    # 先頭ゼロを除去（01 -> 1）
    local month
    month=$((10#$month_padded))

    local archive_dir="${BLOG_DIR}/${year}/${month_padded}"
    local archive_file="${archive_dir}/_index.md"
    local title="${year}年${month}月"

    if [[ "$DRY_RUN" == true ]]; then
        log "  [DRY-RUN] ${archive_file} (${title})"
    else
        mkdir -p "$archive_dir"
        cat > "$archive_file" << EOF
---
title: "${title}"
layout: "archive"
year: ${year}
month: ${month}
---
EOF
        log "  作成: ${archive_file}"
    fi
}

# メイン処理
main() {
    parse_options "$@"
    check_environment

    log_verbose "記事からアーカイブ対象の年月を抽出中..."

    local year_months
    year_months=$(extract_year_months)

    if [[ -z "$year_months" ]]; then
        log "生成するアーカイブはありません"
        exit 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] 以下のアーカイブを生成します:"
    else
        log "アーカイブを生成しています..."
    fi

    local count=0
    while read -r year month; do
        if [[ -n "$year" && -n "$month" ]]; then
            generate_archive "$year" "$month"
            ((++count))
        fi
    done <<< "$year_months"

    if [[ "$DRY_RUN" == true ]]; then
        log "合計: ${count} 件"
    else
        log "完了: ${count} 件のアーカイブを生成しました"
    fi
}

main "$@"
