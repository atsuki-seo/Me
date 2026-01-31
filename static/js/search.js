// ブログ検索機能（Fuse.js使用）
(function() {
    let searchData = [];
    let fuse = null;

    // ページネーション用変数
    let allResults = [];
    let currentPage = 1;
    const resultsPerPage = 5;

    // JSONインデックスの読込
    async function loadSearchIndex() {
        try {
            const response = await fetch('/blog/index.json');
            if (!response.ok) throw new Error('Failed to fetch');
            searchData = await response.json();
            initFuse();

            // 検索結果ページの場合、URLパラメータから検索実行
            if (isSearchPage()) {
                executeSearchFromUrl();
            }
        } catch (error) {
            console.error('検索インデックスの読込に失敗しました:', error);
            if (isSearchPage()) {
                showSearchError();
            }
        }
    }

    // Fuse.js初期化
    function initFuse() {
        if (searchData.length === 0) return;

        fuse = new Fuse(searchData, {
            keys: [
                { name: 'title', weight: 2 },
                { name: 'description', weight: 1.5 },
                { name: 'tags', weight: 1.5 },
                { name: 'content', weight: 1 }
            ],
            threshold: 0.3,
            minMatchCharLength: 2,
            includeScore: true
        });
    }

    // 検索実行
    function performSearch(query) {
        if (!fuse || query.length < 1) return [];

        const results = fuse.search(query);
        return results.map(result => ({
            title: result.item.title,
            url: result.item.url,
            date: result.item.date,
            description: result.item.description,
            tags: result.item.tags || [],
            content: result.item.content || ''
        }));
    }

    // HTMLエスケープ
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // 検索結果ページかどうか判定
    function isSearchPage() {
        return window.location.pathname.startsWith('/blog/search');
    }

    // 検索結果ページに遷移
    function navigateToSearchPage(query) {
        if (query.length > 0) {
            window.location.href = '/blog/search/?q=' + encodeURIComponent(query);
        }
    }

    // URLパラメータから検索実行
    function executeSearchFromUrl() {
        const params = new URLSearchParams(window.location.search);
        const query = params.get('q') || '';

        // 検索クエリ表示を更新
        const queryDisplay = document.getElementById('search-query-display');
        if (queryDisplay) {
            if (query) {
                queryDisplay.textContent = '「' + query + '」の検索結果';
            } else {
                queryDisplay.textContent = '検索キーワードを入力してください';
            }
        }

        // 検索フィールドにクエリをセット
        const searchInput = document.getElementById('search-input');
        if (searchInput && query) {
            searchInput.value = query;
        }

        // 検索実行
        if (query) {
            allResults = performSearch(query);
            currentPage = 1;
            displaySearchPageResults(query);
        } else {
            showEmptyState('検索キーワードを入力してください', 'fa-keyboard');
        }
    }

    // 検索結果ページに結果を表示
    function displaySearchPageResults(query) {
        const resultsDiv = document.getElementById('search-results-page');
        if (!resultsDiv) return;

        if (allResults.length === 0) {
            showEmptyState('「' + escapeHtml(query) + '」に一致する記事が見つかりませんでした', 'fa-search');
            return;
        }

        // ページネーション計算
        const totalPages = Math.ceil(allResults.length / resultsPerPage);
        const startIndex = (currentPage - 1) * resultsPerPage;
        const endIndex = startIndex + resultsPerPage;
        const pageResults = allResults.slice(startIndex, endIndex);

        // 検索結果のHTML生成
        const html = pageResults.map(result => {
            // タグのHTML生成
            const tagsHtml = result.tags.length > 0
                ? `<span class="post-meta-item">
                    <i class="fas fa-tags"></i>
                    ${result.tags.map(tag => `<a href="/tags/${encodeURIComponent(tag)}/" class="tag">${escapeHtml(tag)}</a>`).join('')}
                   </span>`
                : '';

            // 抜粋の生成（最大200文字）
            const excerpt = result.description || (result.content ? result.content.substring(0, 200) + '...' : '');

            return `
            <article class="post-card">
                <h2><a href="${result.url}">${escapeHtml(result.title)}</a></h2>
                <div class="post-meta">
                    <span class="post-meta-item">
                        <i class="fas fa-calendar-alt"></i> ${result.date}
                    </span>
                    ${tagsHtml}
                </div>
                <p class="post-excerpt">${escapeHtml(excerpt)}</p>
                <a href="${result.url}" class="read-more">
                    続きを読む <i class="fas fa-arrow-right"></i>
                </a>
            </article>
            `;
        }).join('');

        // ページネーションUIの生成
        let paginationHtml = '';
        if (totalPages > 1) {
            const prevDisabled = currentPage === 1 ? 'pagination-disabled' : '';
            const nextDisabled = currentPage === totalPages ? 'pagination-disabled' : '';

            paginationHtml = `
            <nav class="pagination">
                <a href="#" class="pagination-link ${prevDisabled}" onclick="window.searchGoToPage(${currentPage - 1}); return false;">
                    <i class="fas fa-chevron-left"></i> 前へ
                </a>
                <span class="pagination-info">${currentPage} / ${totalPages}</span>
                <a href="#" class="pagination-link ${nextDisabled}" onclick="window.searchGoToPage(${currentPage + 1}); return false;">
                    次へ <i class="fas fa-chevron-right"></i>
                </a>
            </nav>
            `;
        }

        resultsDiv.innerHTML = html + paginationHtml;
    }

    // ページ切り替え関数（グローバルに公開）
    window.searchGoToPage = function(page) {
        const totalPages = Math.ceil(allResults.length / resultsPerPage);
        if (page < 1 || page > totalPages) return;

        currentPage = page;

        // URLパラメータからクエリを取得
        const params = new URLSearchParams(window.location.search);
        const query = params.get('q') || '';

        displaySearchPageResults(query);

        // ページトップにスクロール
        window.scrollTo({ top: 0, behavior: 'smooth' });
    };

    // エンプティステート表示
    function showEmptyState(message, icon) {
        const resultsDiv = document.getElementById('search-results-page');
        if (!resultsDiv) return;

        resultsDiv.innerHTML = `
            <div class="search-empty-state">
                <i class="fas ${icon}"></i>
                <p>${message}</p>
            </div>
        `;
    }

    // エラー表示
    function showSearchError() {
        const resultsDiv = document.getElementById('search-results-page');
        if (!resultsDiv) return;

        resultsDiv.innerHTML = `
            <div class="search-empty-state error">
                <i class="fas fa-exclamation-triangle"></i>
                <p>検索インデックスの読み込みに失敗しました</p>
            </div>
        `;
    }

    // 初期化
    document.addEventListener('DOMContentLoaded', function() {
        const searchInput = document.getElementById('search-input');
        if (!searchInput) return;

        // Fuse.js読込後にインデックスをロード
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/fuse.js@7.0.0/dist/fuse.min.js';
        script.onload = loadSearchIndex;
        document.head.appendChild(script);

        // Enterキー / 改行で検索ページに遷移
        searchInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                const query = e.target.value.trim();
                navigateToSearchPage(query);
            }
        });

        // IME確定時の対応（日本語入力）
        searchInput.addEventListener('compositionend', function(e) {
            // compositionend後のEnterは通常のkeydownで処理される
        });
    });
})();
